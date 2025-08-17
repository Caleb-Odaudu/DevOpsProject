#!/bin/bash

SG_ID="sg-0c9cc46bb3fc9c72e"  # Replace with your security group ID
PORT=22
IP=$(curl -s ifconfig.me)

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port "$PORT" \
  --cidr "$IP/32" \
  --output text

echo "✅ SSH access granted for $IP"
