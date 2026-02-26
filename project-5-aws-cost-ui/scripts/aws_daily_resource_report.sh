#!/bin/bash
#
# AWS Daily Resource Usage Report
# Lists EC2 instances, S3 buckets, Lambda functions, EBS volumes with $/hr cost.
# Use with the Cost Dashboard UI (run from project-5-aws-cost-ui).
#
# Prerequisites: AWS CLI installed and configured (aws configure)
# Usage: ./aws_daily_resource_report.sh [optional: output directory]
#

set -e

REPORT_DIR="${1:-.}"
REPORT_DATE=$(date +%Y-%m-%d)
REPORT_TIME=$(date +%H:%M:%S)
REPORT_FILE="${REPORT_DIR}/aws_resource_report_${REPORT_DATE}.txt"
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT INT TERM

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$REPORT_FILE"; }

# Start report
{
  echo "=============================================="
  echo "  AWS Daily Resource Usage Report"
  echo "  Generated: $REPORT_DATE $REPORT_TIME"
  echo "  Costs: EC2 and EBS show estimated \$/hr (approximate)."
  echo "=============================================="
  echo ""
} > "$REPORT_FILE"

# Check AWS CLI
if ! command -v aws &>/dev/null; then
  log "ERROR: AWS CLI not found. Install and configure it first."
  exit 1
fi

get_ec2_hourly_usd() {
  case "$1" in
    t2.nano)   echo "0.0058";;
    t2.micro)  echo "0.0116";;
    t2.small)  echo "0.023";;
    t2.medium) echo "0.0464";;
    t2.large)  echo "0.0928";;
    t3.micro|t3a.micro)  echo "0.0104";;
    t3.small|t3a.small)  echo "0.0208";;
    t3.medium|t3a.medium) echo "0.0416";;
    t3.large|t3a.large)  echo "0.0832";;
    t3.xlarge|t3a.xlarge) echo "0.1664";;
    m5.large)  echo "0.096";;
    m5.xlarge) echo "0.192";;
    m5.2xlarge) echo "0.384";;
    m4.large)  echo "0.1";;
    m4.xlarge) echo "0.2";;
    c5.large)  echo "0.085";;
    c5.xlarge) echo "0.17";;
    *) echo "0";;
  esac
}

EBS_USD_PER_GB_HR="0.0001096"

# --- EC2 Instances ---
log "--- EC2 Instances ---"
if aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,LaunchTime,Tags[?Key==`Name`].Value|[0]]' --output table 2>>"$TMP_DIR/err" >> "$REPORT_FILE"; then
  RUNNING=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`]' --output text 2>/dev/null | grep -c INSTANCES || echo 0)
  STOPPED=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`stopped`]' --output text 2>/dev/null | grep -c INSTANCES || echo 0)
  echo "" >> "$REPORT_FILE"
  echo "Per-instance estimated cost (running only, \$/hr, approximate us-east-1 Linux):" >> "$REPORT_FILE"
  aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output text 2>/dev/null | while read -r iid state itype; do
    [ -z "$iid" ] && continue
    if [ "$state" = "running" ]; then
      rate=$(get_ec2_hourly_usd "$itype")
      printf "  %s  %s  %-12s  \$%s/hr\n" "$iid" "$state" "$itype" "$rate" >> "$REPORT_FILE"
      echo "$rate" >> "$TMP_DIR/ec2_rates"
    fi
  done
  TOTAL_EC2_HR=$(awk '{s+=$1} END {printf "%.4f", s}' "$TMP_DIR/ec2_rates" 2>/dev/null || echo "0")
  rm -f "$TMP_DIR/ec2_rates"
  echo "" >> "$REPORT_FILE"
  log "Summary: Running=$RUNNING, Stopped=$STOPPED | Est. total EC2 (running) \$/hr: \$$TOTAL_EC2_HR (approximate, us-east-1)"
else
  log "EC2: Unable to list (check permissions or region)"
fi
echo "" >> "$REPORT_FILE"

# --- S3 Buckets ---
log "--- S3 Buckets ---"
if aws s3 ls 2>>"$TMP_DIR/err" >> "$REPORT_FILE"; then
  BUCKET_COUNT=$(aws s3 ls 2>/dev/null | wc -l)
  log "Summary: Total buckets=$BUCKET_COUNT"
else
  log "S3: Unable to list (check permissions)"
fi
echo "" >> "$REPORT_FILE"

# --- Lambda Functions ---
log "--- Lambda Functions ---"
if aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table 2>>"$TMP_DIR/err" >> "$REPORT_FILE"; then
  LAMBDA_COUNT=$(aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo 0)
  log "Summary: Total functions=$LAMBDA_COUNT"
else
  log "Lambda: Unable to list (check permissions or region)"
fi
echo "" >> "$REPORT_FILE"

# --- IAM Users ---
log "--- IAM Users ---"
if aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table 2>>"$TMP_DIR/err" >> "$REPORT_FILE"; then
  USER_COUNT=$(aws iam list-users --query 'length(Users)' --output text 2>/dev/null || echo 0)
  log "Summary: Total IAM users=$USER_COUNT"
else
  log "IAM: Unable to list (check permissions)"
fi
echo "" >> "$REPORT_FILE"

# --- EBS Volumes ---
log "--- EBS Volumes (all, with est. \$/hr) ---"
if aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,State,CreateTime]' --output table 2>>"$TMP_DIR/err" >> "$REPORT_FILE"; then
  echo "" >> "$REPORT_FILE"
  echo "Per-volume estimated cost (\$/hr, ~gp3 \$0.08/GB-month):" >> "$REPORT_FILE"
  aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,State]' --output text 2>/dev/null | while read -r vid size_gb state; do
    [ -z "$vid" ] && continue
    cost_hr=$(awk "BEGIN {printf \"%.6f\", $size_gb * $EBS_USD_PER_GB_HR}")
    printf "  %s  %s GB  %-10s  \$%s/hr\n" "$vid" "$size_gb" "$state" "$cost_hr" >> "$REPORT_FILE"
    echo "$cost_hr" >> "$TMP_DIR/ebs_rates"
  done
  TOTAL_EBS_HR=$(awk '{s+=$1} END {printf "%.4f", s}' "$TMP_DIR/ebs_rates" 2>/dev/null || echo "0")
  rm -f "$TMP_DIR/ebs_rates"
  UNATTACHED=$(aws ec2 describe-volumes --filters Name=status,Values=available --query 'length(Volumes)' --output text 2>/dev/null || echo 0)
  log "Summary: Total EBS est. \$/hr: \$$TOTAL_EBS_HR | Unattached volumes: $UNATTACHED"
else
  log "EBS: Unable to list"
fi

echo "" >> "$REPORT_FILE"
log "Report saved to: $REPORT_FILE"
echo "Done. Report: $REPORT_FILE"
