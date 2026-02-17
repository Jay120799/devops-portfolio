#!/bin/bash
# Health check script for all deployed services

echo "============================================"
echo "DevOps Portfolio Health Check"
echo "============================================"
echo ""

# Function to check HTTP endpoint
check_http() {
    local url=$1
    local name=$2
    local status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 $url 2>/dev/null || echo "000")
    
    if [ "$status" -eq "200" ]; then
        echo "✅ $name: OK ($status)"
    else
        echo "❌ $name: FAILED ($status)"
    fi
}

# Get instance IPs (update these)
INSTANCE1_IP="YOUR_INSTANCE1_IP"  # Update this
INSTANCE2_IP="YOUR_INSTANCE2_IP"  # Update this

echo "Project 1: DevSecOps Pipeline"
echo "------------------------------"
check_http "http://$INSTANCE1_IP:8080" "Jenkins"
check_http "http://$INSTANCE2_IP:8001/health" "Flask App"
check_http "http://$INSTANCE2_IP:8002/health" "Node.js App"
check_http "http://$INSTANCE2_IP:8003/health" "Go App"
echo ""

echo "Project 2: Kubernetes + Monitoring"
echo "-----------------------------------"
check_http "http://$INSTANCE2_IP:3000" "Grafana"
check_http "http://$INSTANCE2_IP:9090/-/healthy" "Prometheus"
echo ""

echo "Project 3: GitOps + ArgoCD"
echo "--------------------------"
check_http "http://$INSTANCE1_IP:30443" "ArgoCD"
check_http "http://$INSTANCE2_IP:3000" "Grafana"
check_http "http://$INSTANCE2_IP:9093/-/healthy" "Alertmanager"
echo ""

echo "============================================"
echo "Health check complete"
echo "============================================"
