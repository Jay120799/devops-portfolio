# Troubleshooting Guide

## Common Issues and Solutions

---

## Project 1: DevSecOps Pipeline

### Issue: Jenkins not starting

**Symptoms:**
- `systemctl status jenkins` shows failed
- Cannot access Jenkins on port 8080

**Solutions:**

1. **Check Java version**
```bash
java -version
# Should be Java 11 or higher
sudo apt-get install -y openjdk-11-jdk
```

2. **Check ports**
```bash
sudo netstat -tulpn | grep 8080
# If port is in use, kill the process or change Jenkins port
```

3. **Check logs**
```bash
sudo journalctl -u jenkins -f
sudo cat /var/log/jenkins/jenkins.log
```

4. **Restart Jenkins**
```bash
sudo systemctl restart jenkins
sudo systemctl enable jenkins
```

---

### Issue: Docker permission denied

**Symptoms:**
- `docker ps` returns permission denied
- Cannot build Docker images

**Solutions:**

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Or logout and login again
```

---

### Issue: Ansible connection refused

**Symptoms:**
- `ansible all -m ping` fails
- Cannot SSH to target host

**Solutions:**

1. **Check SSH connectivity**
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@target-ip
```

2. **Update inventory file**
```bash
# Edit ansible/inventory/hosts
[app_servers]
app-server ansible_host=CORRECT-IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem
```

3. **Check security groups**
- Ensure Instance 1 can reach Instance 2 on port 22

---

### Issue: Terraform authentication failed

**Symptoms:**
- `terraform apply` fails with AWS credentials error

**Solutions:**

```bash
# Configure AWS CLI
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"

# Test
aws ec2 describe-instances
```

---

## Project 2 & 3: Kubernetes Issues

### Issue: K3s not starting

**Symptoms:**
- `kubectl get nodes` fails
- K3s service not running

**Solutions:**

```bash
# Check K3s status
sudo systemctl status k3s

# Check logs
sudo journalctl -u k3s -f

# Restart K3s
sudo systemctl restart k3s

# If completely broken, reinstall
/usr/local/bin/k3s-uninstall.sh
curl -sfL https://get.k3s.io | sh -
```

---

### Issue: Pods in CrashLoopBackOff

**Symptoms:**
- `kubectl get pods` shows CrashLoopBackOff
- Applications not accessible

**Solutions:**

1. **Check pod logs**
```bash
kubectl logs POD-NAME -n NAMESPACE
kubectl describe pod POD-NAME -n NAMESPACE
```

2. **Check resources**
```bash
kubectl top nodes
kubectl top pods -A

# If out of memory, enable swap or reduce replicas
```

3. **Check events**
```bash
kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'
```

4. **Restart pod**
```bash
kubectl delete pod POD-NAME -n NAMESPACE
# K8s will recreate it
```

---

### Issue: Unable to connect to K8s API

**Symptoms:**
- `kubectl` commands timeout
- `The connection to the server was refused`

**Solutions:**

```bash
# Check kubeconfig
cat ~/.kube/config

# Copy from K3s
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Set KUBECONFIG
export KUBECONFIG=~/.kube/config

# Test
kubectl cluster-info
```

---

### Issue: ArgoCD UI not accessible

**Symptoms:**
- Cannot access ArgoCD on port 30443
- Connection refused

**Solutions:**

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check service
kubectl get svc -n argocd

# Port forward (alternative)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Then access: https://localhost:8080

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---

## Project 2 & 3: Monitoring Issues

### Issue: Prometheus not scraping metrics

**Symptoms:**
- Prometheus UI shows targets as down
- No data in Grafana

**Solutions:**

1. **Check Prometheus targets**
```bash
# Access Prometheus UI: http://IP:9090
# Go to Status > Targets
```

2. **Check network connectivity**
```bash
# From monitoring instance, test target
curl http://K8S-INSTANCE-IP:10250/metrics
```

3. **Update Prometheus config**
```bash
# Edit prometheus.yml with correct IPs
nano ~/monitoring/prometheus/prometheus.yml

# Restart Prometheus
docker restart prometheus
```

4. **Check firewall**
```bash
# Ensure port 10250 is open between instances
sudo ufw status
sudo ufw allow from MONITORING-IP to any port 10250
```

---

### Issue: Grafana shows "No Data"

**Symptoms:**
- Dashboards load but show no data
- Data source connection fails

**Solutions:**

1. **Check data source**
```bash
# In Grafana UI: Configuration > Data Sources
# Test connection to Prometheus
```

2. **Fix Prometheus URL**
```
# Should be: http://prometheus:9090
# Or: http://localhost:9090
# Not: http://INSTANCE-IP:9090 (if same host)
```

3. **Check time range**
- Ensure dashboard time range includes data
- Try "Last 5 minutes"

4. **Verify Prometheus has data**
```bash
# In Prometheus UI: http://IP:9090
# Execute query: up
# Should show targets
```

---

## General Issues

### Issue: Out of memory

**Symptoms:**
- Processes killed randomly
- `dmesg` shows OOM killer

**Solutions:**

```bash
# Check memory usage
free -h
top

# Enable swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
free -h
```

---

### Issue: Disk space full

**Symptoms:**
- `No space left on device`
- Applications failing to start

**Solutions:**

```bash
# Check disk usage
df -h

# Find large files
du -h / | sort -rh | head -20

# Clean Docker
docker system prune -a -f
docker volume prune -f

# Clean apt cache
sudo apt-get clean
sudo apt-get autoclean

# Clean logs
sudo journalctl --vacuum-time=3d
```

---

### Issue: Security group blocking connections

**Symptoms:**
- Cannot access services from browser
- Connection timeout

**Solutions:**

```bash
# List security groups
aws ec2 describe-security-groups

# Add inbound rule (example: port 8080)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

---

### Issue: SSH connection refused after stop/start

**Symptoms:**
- SSH hangs or refuses connection
- Public IP changed

**Solutions:**

```bash
# Get new public IP
aws ec2 describe-instances --instance-ids i-xxxxx \
  --query 'Reservations[*].Instances[*].PublicIpAddress' --output text

# Update SSH config or reconnect with new IP
ssh -i ~/.ssh/your-key.pem ubuntu@NEW-IP

# Remove old host key if needed
ssh-keygen -R OLD-IP
```

---

## Debugging Commands Cheat Sheet

### Docker
```bash
docker ps -a                    # List all containers
docker logs CONTAINER           # View logs
docker inspect CONTAINER        # Detailed info
docker stats                    # Resource usage
docker system df                # Disk usage
```

### Kubernetes
```bash
kubectl get all -A              # All resources
kubectl describe pod POD        # Detailed info
kubectl logs POD                # View logs
kubectl exec -it POD -- bash    # Shell into pod
kubectl get events              # Cluster events
```

### System
```bash
systemctl status SERVICE        # Service status
journalctl -u SERVICE -f        # Service logs
netstat -tulpn                  # Open ports
top / htop                      # Resource usage
df -h                           # Disk usage
free -h                         # Memory usage
```

### AWS
```bash
aws ec2 describe-instances      # List instances
aws ec2 describe-security-groups  # List security groups
aws logs tail LOG-GROUP --follow  # CloudWatch logs
```

---

## Getting Help

If you're still stuck:

1. **Check logs first** - 90% of issues are explained in logs
2. **Google the error message** - Exact error message in quotes
3. **Stack Overflow** - Search or ask questions
4. **Official docs:**
   - Jenkins: https://www.jenkins.io/doc/
   - Kubernetes: https://kubernetes.io/docs/
   - Docker: https://docs.docker.com/
   - Ansible: https://docs.ansible.com/
   - Terraform: https://www.terraform.io/docs/

---

**Remember:** Most issues in DevOps are related to networking, permissions, or resource constraints. Check those first!
