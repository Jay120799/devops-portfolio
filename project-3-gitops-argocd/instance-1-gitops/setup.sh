#!/bin/bash
set -e

echo "=========================================="
echo "Setting up GitOps Server (Instance 1)"
echo "=========================================="

# Install K3s
curl -sfL https://get.k3s.io | sh -
sleep 10

# Configure kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD
sleep 30

# Expose ArgoCD server
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "nodePort": 30443}]}}'

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "ArgoCD URL: http://$(curl -s ifconfig.me):30443"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "Namespaces created: dev, staging, prod"
echo "=========================================="
