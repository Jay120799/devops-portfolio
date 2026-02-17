#!/bin/bash
# Stop EC2 instances to save free tier hours

set -e

# Check if AWS CLI is configured
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI not installed"
    exit 1
fi

# Configuration (Update these with your instance IDs)
INSTANCE1_ID="i-xxxxx"  # Update with your Instance 1 ID
INSTANCE2_ID="i-yyyyy"  # Update with your Instance 2 ID

echo "============================================"
echo "Stopping EC2 Instances"
echo "============================================"
echo ""

echo "Stopping instances..."
aws ec2 stop-instances --instance-ids $INSTANCE1_ID $INSTANCE2_ID

echo "Waiting for instances to stop..."
aws ec2 wait instance-stopped --instance-ids $INSTANCE1_ID $INSTANCE2_ID

echo ""
echo "Instances stopped successfully!"
echo ""

# Show final status
aws ec2 describe-instances --instance-ids $INSTANCE1_ID $INSTANCE2_ID \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name]' \
  --output table

echo ""
echo "============================================"
echo "Instances stopped. No EC2 hours being used."
echo "Data is preserved on EBS volumes."
echo "============================================"
