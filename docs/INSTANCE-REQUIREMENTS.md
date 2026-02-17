# Instance Requirements - Detailed Guide

## Overview

This document provides detailed instance requirements for each project, helping you understand resource allocation and cost management.

---

## Free Tier Summary

**AWS Free Tier EC2:**
- **750 hours/month** of t3.micro or t2.micro instances
- **1 GB RAM per instance**
- **30 GB EBS storage**
- **100% FREE for first 12 months**

**Your Monthly Budget:**
- 750 hours = **31 days of 1 instance** OR **15 days of 2 instances**
- Practice 2 hours/day with 2 instances = **4 hours/day = 120 hours/month** (16% of free tier)
- **Plenty of room for practice!**

---

## Project 1: DevSecOps CI/CD Pipeline

### Instances: 2 x t3.micro

#### Instance 1: CI/CD Server
```
Type: t3.micro (2 vCPU, 1GB RAM, 20GB disk)
OS: Ubuntu 22.04 LTS
Purpose: CI/CD automation

Software & Memory Usage:
├── Jenkins: ~400MB
├── Docker: ~100MB
├── Ansible: ~50MB
├── Terraform: ~50MB
├── System: ~200MB
└── Total: ~800MB / 1024MB ✅

Ports to Open:
- 22 (SSH)
- 8080 (Jenkins)

Setup Time: 10-15 minutes
Practice Time: 2-3 hours
```

#### Instance 2: Application Server
```
Type: t3.micro (2 vCPU, 1GB RAM, 15GB disk)
OS: Ubuntu 22.04 LTS
Purpose: Run microservices

Software & Memory Usage:
├── Docker: ~100MB
├── Flask App: ~150MB
├── Node.js App: ~200MB
├── Go App: ~50MB
├── Nginx: ~50MB
├── System: ~200MB
└── Total: ~750MB / 1024MB ✅

Ports to Open:
- 22 (SSH)
- 80 (HTTP)
- 8001-8003 (Applications)

Setup Time: 5-10 minutes
Practice Time: 2-3 hours
```

**Total Cost per Practice:**
- 2 instances × 3 hours = 6 hours
- Cost: **$0.00** (within free tier)

---

## Project 2: Kubernetes + Monitoring

### Instances: 2 x t3.micro

#### Instance 1: K8s Cluster
```
Type: t3.micro (2 vCPU, 1GB RAM, 20GB disk)
OS: Ubuntu 22.04 LTS
Purpose: Kubernetes cluster

Software & Memory Usage:
├── K3s: ~512MB (lightweight K8s)
├── 3 App Pods: ~300MB
├── Helm: ~50MB
├── System: ~150MB
└── Total: ~1012MB / 1024MB ⚠️

Note: Will use swap space (enabled automatically)

Ports to Open:
- 22 (SSH)
- 6443 (K8s API)
- 80, 443 (Ingress)
- 30000-32767 (NodePort range)

Setup Time: 15-20 minutes
```

#### Instance 2: Monitoring Stack
```
Type: t3.micro (2 vCPU, 1GB RAM, 15GB disk)
OS: Ubuntu 22.04 LTS
Purpose: Monitoring and observability

Software & Memory Usage:
├── Prometheus: ~300MB
├── Grafana: ~200MB
├── Node Exporter: ~50MB
├── Alertmanager: ~50MB
├── System: ~200MB
└── Total: ~800MB / 1024MB ✅

Ports to Open:
- 22 (SSH)
- 3000 (Grafana)
- 9090 (Prometheus)
- 9093 (Alertmanager)
- 9100 (Node Exporter)

Setup Time: 10-15 minutes
```

**Total Cost per Practice:**
- 2 instances × 3 hours = 6 hours
- Cost: **$0.00** (within free tier)

---

## Project 3: GitOps + ArgoCD

### Instances: 2 x t3.micro

#### Instance 1: GitOps Server
```
Type: t3.micro (2 vCPU, 1GB RAM, 20GB disk)
OS: Ubuntu 22.04 LTS
Purpose: GitOps automation

Software & Memory Usage:
├── K3s: ~512MB
├── ArgoCD: ~250MB
├── App Pods: ~150MB
├── System: ~150MB
└── Total: ~1062MB / 1024MB ⚠️

Note: Will use swap space

Ports to Open:
- 22 (SSH)
- 6443 (K8s API)
- 30443 (ArgoCD UI)
- 80, 443 (Apps)

Setup Time: 15-20 minutes
```

#### Instance 2: Monitoring + Alerts
```
Type: t3.micro (2 vCPU, 1GB RAM, 15GB disk)
Purpose: Monitoring with alerting

Software & Memory Usage:
├── Prometheus: ~300MB
├── Grafana: ~200MB
├── Alertmanager: ~100MB
├── System: ~200MB
└── Total: ~800MB / 1024MB ✅

Ports: Same as Project 2

Setup Time: 10-15 minutes
```

**Total Cost per Practice:**
- 2 instances × 3 hours = 6 hours
- Cost: **$0.00** (within free tier)

---

## Project 4: Security + Serverless

### Instances: 1 x t3.micro + AWS Lambda

#### Instance 1: Security Server
```
Type: t3.micro (2 vCPU, 1GB RAM, 15GB disk)
OS: Ubuntu 22.04 LTS
Purpose: Kubernetes security

Software & Memory Usage:
├── K3s: ~512MB
├── Trivy Scanner: ~100MB
├── Security Policies: ~50MB
├── System: ~200MB
└── Total: ~862MB / 1024MB ✅

Ports to Open:
- 22 (SSH)
- 6443 (K8s API)

Setup Time: 10-15 minutes
```

#### AWS Lambda Functions
```
Type: Serverless (pay per invocation)
Purpose: Automation tasks

Functions:
├── Security Scanner (runs every 6 hours)
├── Cost Optimizer (runs weekly)
├── Backup Automation (runs daily)
├── Log Analyzer (event-driven)
└── Compliance Checker (runs daily)

AWS Free Tier Lambda:
- 1 million requests/month FREE
- 400,000 GB-seconds compute time FREE
- Your usage: ~2,000 requests/month = FREE ✅

Cost: $0.00
```

**Total Cost per Practice:**
- 1 instance × 2 hours = 2 hours
- Lambda: ~10 invocations = FREE
- Cost: **$0.00** (within free tier)

---

## Monthly Cost Calculation

### Scenario: Practice 2 hours/day for 30 days

```
Project 1: 2 instances × 2 hours × 30 days = 120 hours
Project 2: 2 instances × 2 hours × 10 days = 40 hours
Project 3: 2 instances × 2 hours × 10 days = 40 hours
Project 4: 1 instance × 2 hours × 10 days = 20 hours
─────────────────────────────────────────────────────
Total: 220 hours / 750 available = 29% used

Cost: $0.00 ✅
Remaining: 530 hours for more practice!
```

---

## Memory Optimization Tips

### For t3.micro (1GB RAM):

1. **Enable Swap Space**
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

2. **Limit Docker Memory**
```bash
docker run -m 256m your-app
```

3. **Use Lightweight Alternatives**
- K3s instead of full Kubernetes ✅
- Alpine Linux images instead of Ubuntu
- Nginx instead of Apache

4. **Stop Unused Services**
```bash
sudo systemctl stop unneeded-service
```

---

## Security Group Configuration

### Inbound Rules Template

```
CI/CD Server (Project 1 Instance 1):
- SSH: 22 from 0.0.0.0/0
- Jenkins: 8080 from 0.0.0.0/0

App Server (Project 1 Instance 2):
- SSH: 22 from Your IP + Instance 1 IP
- HTTP: 80 from 0.0.0.0/0
- Apps: 8001-8003 from 0.0.0.0/0

K8s Server (Projects 2, 3, 4):
- SSH: 22 from 0.0.0.0/0
- K8s API: 6443 from monitoring instance IP
- HTTP/HTTPS: 80, 443 from 0.0.0.0/0
- NodePorts: 30000-32767 from 0.0.0.0/0

Monitoring Server (Projects 2, 3):
- SSH: 22 from 0.0.0.0/0
- Grafana: 3000 from 0.0.0.0/0
- Prometheus: 9090 from 0.0.0.0/0
- Alertmanager: 9093 from 0.0.0.0/0
```

---

## Stop/Start Best Practices

### After Each Practice Session:

```bash
# Stop instances (keeps data, stops billing hours)
aws ec2 stop-instances --instance-ids i-xxx i-yyy

# Check status
aws ec2 describe-instances --instance-ids i-xxx i-yyy \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
```

### Before Next Practice:

```bash
# Start instances
aws ec2 start-instances --instance-ids i-xxx i-yyy

# Wait for running state
aws ec2 wait instance-running --instance-ids i-xxx i-yyy

# Get new public IPs (IPs change after stop/start!)
aws ec2 describe-instances --instance-ids i-xxx i-yyy \
  --query 'Reservations[*].Instances[*].PublicIpAddress' --output text
```

---

**Key Takeaway:** All 4 projects can run completely FREE within AWS Free Tier with smart resource management!
