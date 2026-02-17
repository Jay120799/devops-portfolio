#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Security Server (Instance 1)"
echo "=========================================="

# Install K3s
curl -sfL https://get.k3s.io | sh -
sleep 10

mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y

# Create RBAC policies
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: secure-apps
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: secure-apps
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: secure-apps
subjects:
- kind: ServiceAccount
  name: default
  namespace: secure-apps
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOF

# Create Network Policy
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: secure-apps
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Scan images with Trivy
echo "Scanning common images for vulnerabilities..."
trivy image nginx:latest
trivy image python:3.9-slim

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "Security Features Enabled:"
echo "  - RBAC Policies"
echo "  - Network Policies"
echo "  - Trivy Scanner Installed"
echo ""
echo "K8s Cluster: $(kubectl get nodes)"
echo "=========================================="
