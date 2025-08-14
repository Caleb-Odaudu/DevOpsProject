#!/bin/bash
set -euo pipefail

source wordpress.env

# Validate required environment variables
validate_env_vars() {
  for var in PRIVATE_DB_SUBNET_1 PRIVATE_DB_SUBNET_2 VPC_ID DB_SG_ID; do
    if [ -z "${!var:-}" ]; then
      echo "❌ Error: $var is not set in wordpress.env"
      exit 1
    fi
  done
}

validate_env_vars

# Check if DB Subnet Group exists
SUBNET_GROUP_NAME="wordpress-db-subnet-group"
EXISTING_SUBNET_GROUP=$(aws rds describe-db-subnet-groups \
  --query "DBSubnetGroups[?DBSubnetGroupName=='$SUBNET_GROUP_NAME'].DBSubnetGroupName" \
  --output text)

if [ "$EXISTING_SUBNET_GROUP" == "$SUBNET_GROUP_NAME" ]; then
  echo "ℹ️ DB Subnet Group '$SUBNET_GROUP_NAME' already exists. Skipping creation."
else
  echo "🔧 Creating DB Subnet Group..."
  aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "Subnet group for WordPress RDS" \
    --subnet-ids "$PRIVATE_DB_SUBNET_1" "$PRIVATE_DB_SUBNET_2"
  echo "✅ DB Subnet Group created."
fi

# Check if RDS instance already exists
DB_IDENTIFIER="wordpress-db"
EXISTING_DB=$(aws rds describe-db-instances \
  --query "DBInstances[?DBInstanceIdentifier=='$DB_IDENTIFIER'].DBInstanceIdentifier" \
  --output text)

if [ "$EXISTING_DB" == "$DB_IDENTIFIER" ]; then
  echo "ℹ️ RDS instance '$DB_IDENTIFIER' already exists. Skipping creation."
else
  echo "🚀 Creating RDS instance '$DB_IDENTIFIER'..."
aws rds create-db-instance \
    --db-instance-identifier "$DB_IDENTIFIER" \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password YourSecurePassword123 \
    --allocated-storage 20 \
    --vpc-security-group-ids "$DB_SG_ID" \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --multi-az \
    --backup-retention-period 7
  echo "✅ RDS instance creation initiated."
fi
