#!/bin/bash
# Start EC2 instances for practice

set -e

# Check if AWS CLI is configured
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI not installed"
    echo "Install: https://aws.amazon.com/cli/"
    exit 1
fi

# Configuration (Update these with your instance IDs)
INSTANCE1_ID="i-xxxxx"  # Update with your Instance 1 ID
INSTANCE2_ID="i-yyyyy"  # Update with your Instance 2 ID

echo "============================================"
echo "Starting EC2 Instances for DevOps Practice"
echo "============================================"
echo ""

echo "Starting instances..."
aws ec2 start-instances --instance-ids $INSTANCE1_ID $INSTANCE2_ID

echo "Waiting for instances to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE1_ID $INSTANCE2_ID

echo ""
echo "Instances started successfully!"
echo ""

# Get instance details
echo "Instance Details:"
aws ec2 describe-instances --instance-ids $INSTANCE1_ID $INSTANCE2_ID \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,PublicIpAddress,State.Name]' \
  --output table

echo ""
echo "SSH Commands:"
IP1=$(aws ec2 describe-instances --instance-ids $INSTANCE1_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
IP2=$(aws ec2 describe-instances --instance-ids $INSTANCE2_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "  Instance 1: ssh -i ~/.ssh/your-key.pem ubuntu@$IP1"
echo "  Instance 2: ssh -i ~/.ssh/your-key.pem ubuntu@$IP2"
echo ""
echo "============================================"
echo "Happy practicing! Remember to stop instances when done."
echo "============================================"
