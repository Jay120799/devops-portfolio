#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Monitoring + Alerts (Instance 2)"
echo "=========================================="

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

mkdir -p ~/monitoring

# Grafana with alerting
docker run -d \
  --name=grafana \
  --restart=always \
  -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  -e "GF_ALERTING_ENABLED=true" \
  grafana/grafana

# Prometheus
cat > ~/monitoring/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes'
    static_configs:
      - targets: ['INSTANCE1-IP:10250']
EOF

docker run -d \
  --name=prometheus \
  --restart=always \
  -p 9090:9090 \
  -v ~/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Alertmanager with Slack integration
cat > ~/monitoring/alertmanager.yml <<EOF
global:
  resolve_timeout: 5m

route:
  receiver: 'default'
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h

receivers:
  - name: 'default'
    webhook_configs:
      - url: 'http://localhost:5001/webhook'  # Configure your webhook
EOF

docker run -d \
  --name=alertmanager \
  --restart=always \
  -p 9093:9093 \
  -v ~/monitoring/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "Grafana: http://$(curl -s ifconfig.me):3000 (admin/admin)"
echo "Prometheus: http://$(curl -s ifconfig.me):9090"
echo "Alertmanager: http://$(curl -s ifconfig.me):9093"
echo "=========================================="
