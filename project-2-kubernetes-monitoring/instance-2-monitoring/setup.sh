#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Monitoring Stack (Instance 2)"
echo "=========================================="

# Update system
sudo apt-get update -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Create directories
mkdir -p ~/monitoring/{prometheus,grafana,alertmanager}

# Prometheus configuration
cat > ~/monitoring/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'kubernetes'
    static_configs:
      - targets: ['INSTANCE1-IP:10250']  # Update with Instance 1 IP
EOF

# Run Prometheus
docker run -d \
  --name=prometheus \
  --restart=always \
  -p 9090:9090 \
  -v ~/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Run Node Exporter
docker run -d \
  --name=node-exporter \
  --restart=always \
  -p 9100:9100 \
  prom/node-exporter

# Run Grafana
docker run -d \
  --name=grafana \
  --restart=always \
  -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  grafana/grafana

# Run Alertmanager
docker run -d \
  --name=alertmanager \
  --restart=always \
  -p 9093:9093 \
  prom/alertmanager

# Wait for services
sleep 10

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "Access URLs:"
echo "  Prometheus: http://$(curl -s ifconfig.me):9090"
echo "  Grafana:    http://$(curl -s ifconfig.me):3000 (admin/admin)"
echo "  Alertmanager: http://$(curl -s ifconfig.me):9093"
echo ""
echo "Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo "=========================================="
