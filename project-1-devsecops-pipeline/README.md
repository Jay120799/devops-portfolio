# Project 1: End-to-End DevSecOps CI/CD Pipeline

## Instances Required: 2 x t3.micro (FREE TIER)

### Instance 1: CI/CD Server
- Jenkins (CI/CD automation)
- Docker (Containerization)
- Ansible (Configuration management)
- Terraform (Infrastructure as Code)
- Git (Version control)

### Instance 2: Application Server
- Docker (Container runtime)
- 3 Microservices (Flask, Node.js, Go)
- Nginx (Reverse proxy)

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│         Instance 1: CI/CD Server (1GB RAM)             │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Jenkins  │  │  Docker  │  │ Ansible  │            │
│  │  :8080   │  │  Engine  │  │Playbooks │            │
│  └──────────┘  └──────────┘  └──────────┘            │
│                                                         │
│  ┌────────────────────────────────────┐               │
│  │       Terraform (IaC)              │               │
│  └────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────┘
                      │
                      │ Deploy via Ansible
                      ▼
┌─────────────────────────────────────────────────────────┐
│       Instance 2: Application Server (1GB RAM)         │
│                                                         │
│  ┌────────────────────────────────────────────────┐   │
│  │           Docker Containers                    │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐   │   │
│  │  │Flask App  │ │Node.js App│ │  Go App   │   │   │
│  │  │  :8001    │ │  :8002    │ │  :8003    │   │   │
│  │  └───────────┘ └───────────┘ └───────────┘   │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────┐              │
│  │       Nginx Reverse Proxy :80       │              │
│  └─────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
```

---

## Setup Instructions

### Prerequisites
1. Launch 2 EC2 t3.micro instances
2. Configure security groups (see below)
3. Clone this repository on both instances

### Security Groups

**Instance 1 Inbound Rules:**
- SSH (22) - Your IP
- HTTP (8080) - 0.0.0.0/0

**Instance 2 Inbound Rules:**
- SSH (22) - Your IP + Instance 1 IP
- HTTP (80) - 0.0.0.0/0
- Custom TCP (8001-8003) - 0.0.0.0/0

---

## Deploy Instance 1 (CI/CD Server)

```bash
# SSH into Instance 1
ssh -i your-key.pem ubuntu@INSTANCE1-IP

# Clone repository
git clone https://github.com/YOUR-USERNAME/devops-portfolio.git
cd devops-portfolio/project-1-devsecops-pipeline/instance-1-cicd

# Run setup script
chmod +x setup.sh
./setup.sh

# Takes 10-15 minutes
# Installs: Jenkins, Docker, Ansible, Terraform
```

---

## Deploy Instance 2 (App Server)

```bash
# SSH into Instance 2
ssh -i your-key.pem ubuntu@INSTANCE2-IP

# Clone repository
git clone https://github.com/YOUR-USERNAME/devops-portfolio.git
cd devops-portfolio/project-1-devsecops-pipeline/instance-2-apps

# Run setup script
chmod +x setup.sh
./setup.sh

# Takes 5-10 minutes
# Deploys 3 containerized microservices
```

---

## Access Services

After deployment:

- **Jenkins:** http://INSTANCE1-IP:8080
  - Get password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
  
- **Flask App:** http://INSTANCE2-IP:8001
- **Node.js App:** http://INSTANCE2-IP:8002  
- **Go App:** http://INSTANCE2-IP:8003
- **Nginx (All Apps):** http://INSTANCE2-IP

---

## CI/CD Pipeline Flow

```
1. Code Commit → Git Push
   ↓
2. Jenkins Webhook Triggered
   ↓
3. Build Stage (Checkout, Install deps, Test)
   ↓
4. Docker Build (Create container images)
   ↓
5. Push Images (To Docker Hub/ECR)
   ↓
6. Deploy Stage (Ansible playbook)
   ↓
7. Health Check & Notification
```

---

## Technologies Used

- **Jenkins** - CI/CD automation
- **Docker** - Containerization
- **Ansible** - Configuration management
- **Terraform** - Infrastructure as Code
- **Python/Flask** - Microservice
- **Node.js/Express** - Microservice  
- **Go** - Microservice
- **Nginx** - Reverse proxy
- **Git** - Version control

---

## Interview Talking Points

### "Walk me through your CI/CD pipeline"
> "I built an end-to-end pipeline using Jenkins that automates the entire deployment. When code is pushed to Git, Jenkins webhook triggers a multi-stage pipeline: checkout, build, test, dockerize, and deploy. Ansible handles deployment to the app server with health checks and automatic rollback on failure."

### "How do you handle failures?"
> "Each pipeline stage has error checking. If any stage fails, the pipeline stops. During deployment, Ansible performs health checks, and if the new version fails, it automatically rolls back to the previous version. We also have post-build notifications for the team."

### "How is security integrated?"
> "Security is built-in at multiple levels. Jenkins uses RBAC, credentials are never in code, and the pipeline includes security scanning stages. We can integrate tools like Trivy for container vulnerability scanning. Ansible Vault encrypts sensitive data."

---

## Cost Estimation

**Practice Session (3 hours):**
- 2 x t3.micro x 3 hours = 6 hours
- Free Tier: 750 hours/month
- **Cost: $0.00**

**Stop instances after practice:**
```bash
aws ec2 stop-instances --instance-ids i-xxx i-yyy
```

---

## Next Steps

After mastering Project 1, move to **Project 2** to add Kubernetes and monitoring!
