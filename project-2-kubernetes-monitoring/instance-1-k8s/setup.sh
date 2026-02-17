#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Kubernetes Cluster (Instance 1)"
echo "=========================================="

# Update system
sudo apt-get update -y

# Install K3s (lightweight Kubernetes)
echo "Installing K3s..."
curl -sfL https://get.k3s.io | sh -

# Wait for K3s to be ready
sleep 10

# Configure kubectl for current user
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
export KUBECONFIG=~/.kube/config

# Install Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Create namespace for applications
kubectl create namespace apps

# Deploy sample Flask app
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: python:3.9-slim
        command: ["/bin/sh"]
        args: ["-c", "pip install flask && python -c 'from flask import Flask; app = Flask(__name__); @app.route(\"/\") \ndef home(): return \"Flask App on K8s\"; @app.route(\"/health\") \ndef health(): return {\"status\":\"healthy\"}; app.run(host=\"0.0.0.0\", port=8001)'"]
        ports:
        - containerPort: 8001
---
apiVersion: v1
kind: Service
metadata:
  name: flask-svc
  namespace: apps
spec:
  type: NodePort
  ports:
  - port: 8001
    targetPort: 8001
    nodePort: 30001
  selector:
    app: flask-app
EOF

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "K8s Cluster Info:"
kubectl get nodes
echo ""
echo "Deployed Apps:"
kubectl get pods -n apps
echo ""
echo "Services:"
kubectl get svc -n apps
echo ""
echo "Access app: http://$(curl -s ifconfig.me):30001"
echo "=========================================="
