#!/bin/bash
set -euo pipefail

source wordpress.env

validate_env_vars() {
  for var in PUBLIC_SUBNET_1 PUBLIC_SUBNET_2 VPC_ID; do
    if [ -z "${!var:-}" ]; then
      echo "❌ Error: $var is not set"
      exit 1
    fi
  done
}

validate_env_vars
# Check if the security group already exists
EXISTING_SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=wordpress-alb-sg Name=vpc-id,Values="$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null || echo "")

if [ -n "$EXISTING_SG_ID" ] && [ "$EXISTING_SG_ID" != "None" ]; then
  echo "ℹ️ Security group 'wordpress-alb-sg' already exists. Using existing SG_ID: $EXISTING_SG_ID"
  SG_ID="$EXISTING_SG_ID"
else
  echo "🔧 Creating ALB security group..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name wordpress-alb-sg \
    --description "Security group for WordPress ALB" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text)

  # Add inbound rules (HTTP and HTTPS)
  for port in 80 443; do
    aws ec2 authorize-security-group-ingress \
      --group-id "$SG_ID" \
      --protocol tcp \
      --port "$port" \
      --cidr 0.0.0.0/0
  done
fi
# Create the ALB
echo "🚀 Creating Application Load Balancer..."
aws elbv2 create-load-balancer \
  --name wordpress-alb \
  --subnets "$PUBLIC_SUBNET_1" "$PUBLIC_SUBNET_2" \
  --security-groups "$SG_ID" \
  --scheme internet-facing \
  --type application
