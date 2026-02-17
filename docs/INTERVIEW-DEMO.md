# Interview Demo Script

## Preparation (Before Interview)

### 1. Resume/Portfolio Setup
- Add GitHub repository link to resume
- Prepare 30-second elevator pitch about your portfolio
- Have EC2 instances ready (stopped to save costs)
- Test SSH access beforehand

### 2. Demo Environment Ready
- AWS Console open in browser tab
- Terminal/SSH client ready
- GitHub repository URL bookmarked

---

## Live Demo Script (15 minutes)

### Opening (1 minute)

**You say:**
> "I've built a comprehensive DevOps portfolio with 4 production-ready projects demonstrating end-to-end CI/CD, Kubernetes orchestration, GitOps practices, and security automation. All projects are fully automated with infrastructure as code and run on AWS free tier. Would you like me to deploy one live right now?"

### Project Selection (30 seconds)

**Interviewer likely asks about:** CI/CD or Kubernetes

**Be ready to demo:**
- Project 1 (CI/CD) - Most common request
- Project 2 (Kubernetes) - If they want to see K8s skills

---

## Demo: Project 1 (CI/CD Pipeline)

### Step 1: Start Instances (2 minutes)

```bash
# Show AWS Console
"Let me start my EC2 instances..."

aws ec2 start-instances --instance-ids i-xxxxx i-yyyyy
aws ec2 wait instance-running --instance-ids i-xxxxx i-yyyyy

# Get IPs
aws ec2 describe-instances --instance-ids i-xxxxx i-yyyyy \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
  --output table
```

**While waiting, explain:**
> "I have 2 t3.micro instances - one for CI/CD tooling with Jenkins, Docker, Ansible, and Terraform, and another for running the microservices. Everything is automated with setup scripts."

### Step 2: SSH and Deploy Instance 1 (4 minutes)

```bash
# SSH into CI/CD server
ssh -i ~/.ssh/your-key.pem ubuntu@INSTANCE1-IP

# Clone and deploy
git clone https://github.com/YOUR-USERNAME/devops-portfolio.git
cd devops-portfolio/project-1-devsecops-pipeline/instance-1-cicd
./setup.sh
```

**While script runs, explain architecture:**
> "The setup script is installing Jenkins for CI/CD automation, Docker for containerization, Ansible for configuration management, and Terraform for infrastructure provisioning. This demonstrates infrastructure as code - everything is reproducible."

> "In a real scenario, I'd use Terraform to provision these instances automatically, but for the demo I'm using existing ones to save time."

**Show the Jenkinsfile:**
```bash
cat jenkins/Jenkinsfile
```

> "This is my Jenkins pipeline with multiple stages: checkout, build, test, Docker image creation, security scanning, and deployment via Ansible. Each stage has error handling and the pipeline stops on failure."

### Step 3: Deploy Instance 2 (3 minutes)

Open new terminal tab:

```bash
# SSH into app server
ssh -i ~/.ssh/your-key.pem ubuntu@INSTANCE2-IP

cd devops-portfolio/project-1-devsecops-pipeline/instance-2-apps
./setup.sh
```

**While deploying:**
> "Instance 2 is deploying 3 microservices - Flask, Node.js, and Go - each in separate Docker containers. They're behind an Nginx reverse proxy. This demonstrates container orchestration and service management."

### Step 4: Show Results (3 minutes)

**Open browser, show:**

1. **Jenkins** (`http://INSTANCE1-IP:8080`)
```bash
# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

> "Here's Jenkins running. In production, I'd have pipelines configured to auto-deploy on Git commits. The webhook triggers the pipeline, runs tests, builds Docker images, scans for security vulnerabilities, and deploys via Ansible."

2. **Applications** 
- `http://INSTANCE2-IP:8001` (Flask)
- `http://INSTANCE2-IP:8002` (Node.js)  
- `http://INSTANCE2-IP:8003` (Go)

> "Here are the 3 microservices running. Each returns JSON with app info and health status. They're containerized, making them portable across environments."

3. **Show Docker**
```bash
docker ps
curl http://localhost:8001/health
```

### Step 5: Explain Ansible Integration (1 minute)

```bash
cat ansible/playbooks/deploy.yml
```

> "This Ansible playbook automates deployment to the app server. It pulls Docker images, deploys containers, performs health checks, and can rollback on failure. Jenkins calls this playbook in the deploy stage."

### Step 6: Show Terraform (1 minute)

```bash
cat terraform/main.tf
```

> "Here's the Terraform configuration for provisioning EC2 instances, security groups, and IAM roles. This makes the entire infrastructure reproducible and version-controlled."

---

## Alternative Demo: Project 2 (Kubernetes)

If they ask about Kubernetes:

```bash
# Deploy K8s cluster (Instance 1)
cd project-2-kubernetes-monitoring/instance-1-k8s
./setup.sh

# While running, explain:
"I'm using K3s, a lightweight Kubernetes distribution perfect for resource-constrained environments. It uses 512MB RAM compared to 2GB+ for full Kubernetes."

# Show K8s resources
kubectl get nodes
kubectl get pods -n apps
kubectl get svc -n apps

"I've deployed applications as Kubernetes pods, with services for networking and ingress for external access."

# Deploy monitoring (Instance 2)
cd project-2-kubernetes-monitoring/instance-2-monitoring
./setup.sh

# Show Grafana
"Here's Grafana with Prometheus integration. It's scraping metrics from the Kubernetes cluster, giving us full observability."

# Open browser: http://INSTANCE2-IP:3000
"This is my SPOG - Single Pane of Glass dashboard - showing cluster health, pod metrics, and application performance."
```

---

## Handling Common Interview Questions

### Q: "Walk me through your CI/CD pipeline"

**Answer:**
> "My pipeline has 6 main stages. First, code checkout from Git. Second, build stage where dependencies are installed and applications are compiled. Third, automated testing - unit tests, integration tests. Fourth, Docker image creation and tagging. Fifth, security scanning with tools like Trivy to detect vulnerabilities. Sixth, deployment via Ansible to the target environment with health checks. The entire process is automated - a developer just pushes code and it flows through the pipeline to production."

### Q: "How do you handle pipeline failures?"

**Answer:**
> "I have multiple failure handling mechanisms. Each stage has error checking - if anything fails, the pipeline stops immediately to prevent bad code from progressing. In the deployment stage, Ansible performs health checks on the deployed containers. If health checks fail, Ansible automatically rolls back to the previous version. We also have post-build actions that send notifications via Slack or email so the team is immediately aware of failures."

### Q: "How is this secured?"

**Answer:**
> "Security is integrated at multiple levels. Jenkins uses role-based access control - only authorized users can trigger pipelines. All credentials are stored in Jenkins credential manager, never in code. The pipeline includes a security scanning stage with Trivy that checks Docker images for known vulnerabilities. For Kubernetes, I've implemented RBAC policies, network policies to control pod-to-pod communication, and pod security standards. Ansible playbooks use Ansible Vault for encrypting sensitive data."

### Q: "How does this scale?"

**Answer:**
> "The architecture is designed for scalability. Applications are containerized, making them portable across environments. With Kubernetes, we can use Horizontal Pod Autoscalers to automatically scale pods based on CPU/memory usage. The Jenkins pipeline is modular - we can easily add more applications or stages. Terraform makes it simple to provision additional infrastructure. For production, I'd recommend using managed Kubernetes like EKS and a container registry like ECR for better scalability."

### Q: "What about monitoring and observability?"

**Answer:**
> "That's Project 2. I've implemented a full monitoring stack with Prometheus for metrics collection and Grafana for visualization. Prometheus scrapes metrics from Kubernetes, applications, and infrastructure. Grafana provides dashboards showing cluster health, pod metrics, application performance, and infrastructure status. I've also configured Alertmanager for notifications - if CPU usage exceeds 80% or pods fail, alerts go to Slack. This gives us full observability into the system."

### Q: "Tell me about GitOps"

**Answer:**
> "That's Project 3 with ArgoCD. GitOps treats Git as the single source of truth for infrastructure and applications. All Kubernetes manifests and Helm charts are stored in Git. ArgoCD watches the Git repository and automatically syncs any changes to the Kubernetes cluster. If I update a deployment in Git, ArgoCD detects the change and applies it to K8s automatically. This provides audit trails, easy rollbacks, and declarative infrastructure. It's much more reliable than manual kubectl commands."

---

## Closing (30 seconds)

**After demo:**
> "All code is in my GitHub repository, fully documented with READMEs and setup scripts. I've designed everything to run on AWS free tier, demonstrating cost optimization skills. I'm happy to discuss any specific component in more detail or answer technical questions about the implementation."

**Then ask:**
> "Do you have any questions about the architecture or implementation? I can dive deeper into any area."

**Stop instances immediately:**
```bash
aws ec2 stop-instances --instance-ids i-xxxxx i-yyyyy
```

---

## Key Points to Emphasize

1. ✅ **Automation** - Everything is scripted and reproducible
2. ✅ **Production-Ready** - Follows industry best practices
3. ✅ **Security** - Integrated at every level
4. ✅ **Cost-Conscious** - Designed for free tier
5. ✅ **Scalable** - Can grow with demand
6. ✅ **Observable** - Full monitoring and alerting
7. ✅ **Modern Practices** - DevSecOps, GitOps, IaC

---

## What NOT to Say

❌ "This is just a simple project"
❌ "I followed a tutorial"
❌ "I'm not sure how this works"
❌ "I haven't tested this in production"

---

## Backup Plan

If instances take too long to start or scripts fail:
- Have screenshots ready
- Show the code and explain architecture
- Walk through the GitHub repository
- Explain what *would* happen if you deployed it

Remember: **Confidence and clear explanation matter more than a perfect demo!**
