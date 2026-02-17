# Project 4: Kubernetes Security and Serverless Automation

## Instances Required: 1 x t3.micro + AWS Lambda (FREE TIER)

### Instance 1: Security Server
- K3s Kubernetes
- Trivy (container vulnerability scanning)
- RBAC policies
- Network policies
- Pod Security Standards

### AWS Lambda Functions (Serverless)
- Security scanner automation
- Cost optimizer
- Backup automation
- Log analyzer

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│    Instance 1: Security Server (1GB RAM)               │
│  ┌──────────────────────────────────────────────────┐  │
│  │         K3s with Security Hardening              │  │
│  │  - RBAC (Role-Based Access Control)             │  │
│  │  - Network Policies                              │  │
│  │  - Pod Security Standards                        │  │
│  │  - Resource Quotas                               │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Trivy Security Scanner                   │  │
│  │  - Scans container images                        │  │
│  │  - Detects vulnerabilities                       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│           AWS Lambda Functions (Serverless)            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Security    │  │     Cost     │  │   Backup     │ │
│  │   Scanner    │  │  Optimizer   │  │  Automation  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│  ┌──────────────┐  ┌──────────────┐                   │
│  │     Log      │  │  Compliance  │                   │
│  │   Analyzer   │  │    Check     │                   │
│  └──────────────┘  └──────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

---

## Setup Instructions

### Deploy Instance 1 (Security)
```bash
cd instance-1-security
./setup.sh
```

### Deploy Lambda Functions
```bash
cd lambda-functions/terraform
terraform init
terraform apply
```

---

## Access Services

- **K8s API:** https://INSTANCE1-IP:6443
- **Trivy Scans:** Check logs
- **Lambda Functions:** AWS Console

---

## Security Features

- **RBAC:** Fine-grained access control
- **Network Policies:** Pod-to-pod security
- **Trivy:** Automated vulnerability scanning
- **Pod Security:** Enforced security standards
- **Secrets Management:** Encrypted secrets

## Lambda Automation

- **Security Scanner:** Scans images every 6 hours
- **Cost Optimizer:** Right-sizes pods weekly
- **Backup Automation:** Daily K8s backups to S3
- **Log Analyzer:** Detects suspicious activity
- **Compliance Check:** Validates security policies

---

## Cost: $0.00 (2 hours per practice + Lambda free tier)
