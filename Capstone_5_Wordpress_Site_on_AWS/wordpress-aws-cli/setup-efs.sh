#!/bin/bash
set -euo pipefail

# === Load Environment ===
source wordpress.env

# === Config ===
REGION="${AWS_REGION:-us-east-1}"
EFS_NAME="${EFS_NAME:-Digitalboost-efs}"
SECURITY_GROUP_ID="${DB_SG_ID}"  # Or use a dedicated SG for EFS
MOUNT_POINT="${MOUNT_POINT:-/mnt/efs}"


# === Subnet Array ===
SUBNET_IDS=(
  "$PRIVATE_APP_SUBNET_1"
  "$PRIVATE_APP_SUBNET_2"
  "$PRIVATE_DB_SUBNET_1"
  "$PRIVATE_DB_SUBNET_2"
)

# === Functions ===

create_efs() {
  echo "Creating EFS file system..." >&2
  local token="${EFS_NAME}-$(date +%s)"
  local fs_id
  fs_id=$(aws efs create-file-system \
    --creation-token "$token" \
    --performance-mode generalPurpose \
    --throughput-mode bursting \
    --tags Key=Name,Value="$EFS_NAME" \
    --region "$REGION" \
    --query 'FileSystemId' --output text)
  echo "EFS created: $fs_id" >&2
  echo "$fs_id"
}

wait_for_efs() {
  local fs_id="$1"
  echo "Waiting for EFS $fs_id to become available..."

  local attempts=0
  local max_attempts=30  # ~2.5 minutes

  while [[ $attempts -lt $max_attempts ]]; do
    local status
    status=$(aws efs describe-file-systems \
      --file-system-id "$fs_id" \
      --region "$REGION" \
      --query 'FileSystems[0].LifeCycleState' \
      --output text)

    echo "Current status: $status"

    if [[ "$status" == "available" ]]; then
      echo "EFS $fs_id is now available."
      return 0
    fi

    ((attempts++))
    sleep 5
  done

  echo "Timeout: EFS $fs_id did not become available after $((max_attempts * 5)) seconds."
  return 1
}

create_mount_targets() {
  local fs_id="$1"
  echo " Creating mount targets for EFS $fs_id..."

  for subnet_id in "${SUBNET_IDS[@]}"; do
    echo "Subnet: $subnet_id"
    aws efs create-mount-target \
      --file-system-id "$fs_id" \
      --subnet-id "$subnet_id" \
      --security-groups "$SECURITY_GROUP_ID" \
      --region "$REGION"
  done

  echo "All mount targets created."
}



# === Main ===
main() {
  echo "Starting EFS provisioning..."
  local fs_id
  fs_id=$(create_efs)
  wait_for_efs "$fs_id"
  create_mount_targets "$fs_id"
  echo "EFS setup complete."
}

main "$@"
