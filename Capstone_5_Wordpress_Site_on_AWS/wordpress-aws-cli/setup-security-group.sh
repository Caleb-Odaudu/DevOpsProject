#!/bin/bash
set -euo pipefail

# Region and VPC setup
REGION="eu-west-2"
VPC_ID="$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[0].VpcId' --output text)"

# Security group definitions
declare -A SG_NAMES=(
  [ALB]="wordpress-alb-sg"
  [SSH]="wordpress-ssh-sg"
  [WEB]="wordpress-web-sg"
  [DB]="wordpress-db-sg"
  [EFS]="wordpress-efs-sg"
)

declare -A SG_DESCRIPTIONS=(
  [ALB]="Allow HTTP/HTTPS traffic to ALB"
  [SSH]="Allow SSH access"
  [WEB]="Allow web traffic to EC2"
  [DB]="Allow MySQL access from web tier"
  [EFS]="Allow NFS access from web tier"
)

declare -A SG_IDS

# Create SG if not exists
create_security_group() {
  local key="$1"
  local name="${SG_NAMES[$key]}"
  local desc="${SG_DESCRIPTIONS[$key]}"

  echo "🔍 Checking for Security Group '$name'..."
  SG_ID=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values="$name" Name=vpc-id,Values="$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)

  if [[ "$SG_ID" == "None" || -z "$SG_ID" ]]; then
    echo "🛠️ Creating Security Group '$name'..."
    SG_ID=$(aws ec2 create-security-group \
      --group-name "$name" \
      --description "$desc" \
      --vpc-id "$VPC_ID" \
      --region "$REGION" \
      --query 'GroupId' --output text)
  else
    echo "ℹ️ Security Group '$name' already exists."
  fi

  SG_IDS[$key]="$SG_ID"
}

# Add ingress rule if not duplicate
authorize_ingress_rule() {
  local sg_id="$1"
  local protocol="$2"
  local port="$3"
  local cidr="$4"

  echo "🔐 Authorizing ingress: $protocol $port from $cidr on SG $sg_id..."

  aws ec2 authorize-security-group-ingress \
    --group-id "$sg_id" \
    --protocol "$protocol" \
    --port "$port" \
    --cidr "$cidr" 2>&1 | grep -q "InvalidPermission.Duplicate" && \
    echo "ℹ️ Rule already exists, skipping." || true
}

# Main execution
for key in "${!SG_NAMES[@]}"; do
  create_security_group "$key"
done

# Ingress rules
authorize_ingress_rule "${SG_IDS[ALB]}" "tcp" 80 "0.0.0.0/0"
authorize_ingress_rule "${SG_IDS[ALB]}" "tcp" 443 "0.0.0.0/0"
authorize_ingress_rule "${SG_IDS[SSH]}" "tcp" 22 "0.0.0.0/0"
authorize_ingress_rule "${SG_IDS[WEB]}" "tcp" 80 "0.0.0.0/0"
authorize_ingress_rule "${SG_IDS[WEB]}" "tcp" 443 "0.0.0.0/0"

# Assume web tier CIDR is internal (adjust as needed)
WEB_SG_CIDR="10.0.0.0/16"
authorize_ingress_rule "${SG_IDS[DB]}" "tcp" 3306 "$WEB_SG_CIDR"
authorize_ingress_rule "${SG_IDS[EFS]}" "tcp" 2049 "$WEB_SG_CIDR"

echo "✅ Security group provisioning complete."
