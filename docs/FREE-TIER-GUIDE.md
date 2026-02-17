# AWS Free Tier Guide - Stay at $0.00

## Free Tier Limits

### EC2 (Compute)
- **750 hours/month** of t2.micro or t3.micro instances
- **Valid for 12 months** from AWS account creation
- **1 GB RAM** per instance
- **30 GB EBS** storage (General Purpose SSD)

### Other Services (Relevant to Projects)
- **S3:** 5 GB storage, 20,000 GET requests, 2,000 PUT requests
- **Lambda:** 1 million requests/month, 400,000 GB-seconds compute
- **CloudWatch:** 10 metrics, 10 alarms, 1 million API requests
- **SNS:** 1,000 email notifications
- **ECR:** 500 MB storage/month
- **Data Transfer:** 15 GB outbound/month

---

## Hour Calculation

```
1 instance running 24/7 for 1 month:
24 hours × 31 days = 744 hours

2 instances running 24/7:
2 × 744 = 1,488 hours (EXCEEDS free tier!)

2 instances for 2 hours/day:
2 instances × 2 hours × 30 days = 120 hours ✅ FREE
```

---

## Your Monthly Usage (All 4 Projects)

### Conservative Practice Schedule

```
Monday:    Project 1 (2 instances × 2 hours) = 4 hours
Tuesday:   Project 2 (2 instances × 2 hours) = 4 hours
Wednesday: Project 3 (2 instances × 2 hours) = 4 hours
Thursday:  Project 4 (1 instance × 2 hours)  = 2 hours
Friday:    Project 1 (review, 2 × 1 hour)    = 2 hours

Weekly Total: 16 hours
Monthly Total (4 weeks): 64 hours

64 hours / 750 available = 8.5% of free tier used ✅
Cost: $0.00
```

### Intensive Practice Schedule

```
Every Day: Rotate through all projects
- 2 instances × 3 hours × 30 days = 180 hours

180 hours / 750 available = 24% of free tier used ✅
Cost: $0.00
```

---

## Cost-Saving Strategies

### 1. Stop Instances Immediately After Use

**Why:** Stopped instances don't count toward free tier hours

```bash
# After practice session
aws ec2 stop-instances --instance-ids i-xxxxx i-yyyyy

# Verify stopped
aws ec2 describe-instances --instance-ids i-xxxxx \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
```

**Stopped instances:**
- ✅ Keep all data on EBS volumes
- ✅ Don't consume EC2 hours
- ✅ Still incur minimal EBS storage charges (covered by free tier)

### 2. Use Elastic IPs Wisely

**Problem:** Public IPs change when you stop/start instances

**Solution Options:**

**Option A: Use Elastic IP (Free with running instance)**
```bash
# Allocate Elastic IP
aws ec2 allocate-address

# Associate with instance
aws ec2 associate-address \
  --instance-id i-xxxxx \
  --allocation-id eipalloc-xxxxx
```

**Warning:** Elastic IPs cost $0.005/hour when NOT associated with a running instance!
- Running: FREE ✅
- Stopped: $3.60/month per IP ❌

**Option B: Use DNS (Free)**
- Get IP after each start
- Update DNS A record (if using custom domain)
- Or just note the new IP for SSH

**Recommendation:** For portfolio/practice, just get new IPs. For production demo, use Elastic IP.

### 3. Optimize Instance Types

**Free Tier Eligible:**
- t2.micro (1 GB RAM, 1 vCPU)
- t3.micro (1 GB RAM, 2 vCPU) ← **Recommended**

**NOT Free Tier:**
- t2.small (2 GB RAM) - costs ~$0.023/hour = $17/month
- t3.small (2 GB RAM) - costs ~$0.021/hour = $15/month

### 4. Use Swap Space for Memory

If you exceed 1GB RAM:

```bash
# Create 2GB swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**Note:** Swap is slower than RAM, but prevents out-of-memory crashes

### 5. Minimize Data Transfer

**Free tier:** 15 GB outbound/month

**Tips:**
- Don't upload/download large files repeatedly
- Use regional resources (avoid cross-region transfer)
- Docker images from public registries don't count toward your transfer

---

## Monitoring Your Usage

### AWS Free Tier Dashboard

1. Go to: https://console.aws.amazon.com/billing/home#/freetier
2. Monitor:
   - EC2 hours used
   - Data transfer
   - Other services

### CloudWatch Billing Alerts (FREE)

```bash
# Set up billing alert for $1 (early warning)
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert \
  --alarm-description "Alert when bill exceeds $1" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 1.0 \
  --comparison-operator GreaterThanThreshold
```

### Check Current Month Usage

```bash
# Get running instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,LaunchTime,State.Name]' \
  --output table
```

---

## What Costs Money (Avoid!)

### Common Billing Surprises

1. **Elastic IP not attached to running instance**
   - Cost: $0.005/hour = $3.60/month
   - Solution: Release when not needed

2. **Running t2.small or larger instances**
   - Cost: $0.023+/hour
   - Solution: Only use t2.micro or t3.micro

3. **EBS volumes over 30GB**
   - Free: 30 GB
   - Cost: $0.10/GB-month for additional
   - Solution: Keep volumes ≤ 30GB

4. **Data transfer over 15GB/month**
   - Cost: $0.09/GB after 15 GB
   - Solution: Don't repeatedly download large files

5. **Snapshots**
   - Cost: $0.05/GB-month
   - Solution: Delete old snapshots, only keep necessary ones

6. **Load Balancer**
   - NOT free tier eligible
   - Cost: ~$16/month
   - Solution: Use Nginx instead

7. **NAT Gateway**
   - NOT free tier eligible
   - Cost: ~$32/month
   - Solution: Use public IPs and security groups

---

## Sample Bill After 1 Month

### Good Practice (Following this guide):

```
EC2 Instances: 120 hours / 750 free hours = $0.00
EBS Storage: 30 GB / 30 GB free = $0.00
Data Transfer: 5 GB / 15 GB free = $0.00
Lambda: 100 invocations / 1M free = $0.00
S3: 1 GB / 5 GB free = $0.00

Total: $0.00 ✅
```

### Bad Practice (Running 24/7):

```
EC2 Instances: 1,488 hours (2 instances × 744)
Free: 750 hours
Overage: 738 hours × $0.0116/hour = $8.56

EBS Storage: 50 GB
Free: 30 GB
Overage: 20 GB × $0.10/month = $2.00

Total: $10.56/month ❌
```

---

## Best Practices Summary

1. ✅ **Stop instances after every practice session**
2. ✅ **Use t3.micro instances only**
3. ✅ **Keep EBS volumes ≤ 30GB**
4. ✅ **Monitor free tier usage weekly**
5. ✅ **Set up billing alerts at $1**
6. ✅ **Delete unused resources**
7. ✅ **Use K3s instead of full Kubernetes**
8. ✅ **Leverage free tier services (Lambda, S3, CloudWatch)**

---

## After Free Tier Expires (12 months)

### Costs with Same Usage Pattern

```
EC2 t3.micro: $0.0104/hour
120 hours/month: $1.25/month
240 hours/month: $2.50/month

Still very affordable! ✅
```

### Cost Reduction Strategies

1. **AWS Educate/Student:** Extra credits if you're a student
2. **AWS Credits:** Apply for startup credits
3. **Lightsail:** Fixed $3.50/month for similar specs
4. **Oracle Cloud:** Permanent free tier (2 VMs, 1GB RAM each)
5. **Google Cloud:** $300 credit for 90 days

---

**Bottom Line:** Follow this guide and you'll stay at **$0.00/month** throughout your free tier period!
