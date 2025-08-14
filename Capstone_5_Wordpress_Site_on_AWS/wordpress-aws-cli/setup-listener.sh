#!/bin/bash
set -euo pipefail

source wordpress.env

validate_env_vars() {
  for var in VPC_ID ASG_NAME; do
    if [ -z "${!var:-}" ]; then
      echo "❌ Error: $var is not set"
      exit 1
    fi
  done
}

validate_env_vars

echo "🔧 Creating Target Group..."
TG_ARN=$(MSYS_NO_PATHCONV=1 aws elbv2 create-target-group \
  --name wordpress-asg-tg \
  --protocol HTTP \
  --port 80 \
  --target-type instance \
  --vpc-id "$VPC_ID" \
  --health-check-path '/wp-login.php' \
  --health-check-protocol HTTP \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

echo "✅ Target Group created: $TG_ARN"


# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names wordpress-alb \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

# Create Listener
echo "🔗 Creating Listener..."
aws elbv2 create-listener \
  --load-balancer-arn "$ALB_ARN" \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn="$TG_ARN"

echo "✅ Listener created and linked to Target Group"

# Attach Target Group to Auto Scaling Group
echo "🔗 Attaching Target Group to Auto Scaling Group..."
aws autoscaling attach-load-balancer-target-groups \
  --auto-scaling-group-name "$ASG_NAME" \
  --target-group-arns "$TG_ARN"

echo "✅ Target Group attached to Auto Scaling Group"
