#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Application Server (Instance 2)"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

# Install Nginx
echo "Installing Nginx..."
sudo apt-get install -y nginx

# Create application directories
mkdir -p ~/apps/{flask-app,nodejs-app,go-app}

echo "Creating Flask Application..."
cat > ~/apps/flask-app/app.py << 'EOF'
from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'app': 'Flask Microservice',
        'version': '1.0.0',
        'hostname': socket.gethostname(),
        'message': 'Hello from Flask!',
        'status': 'running'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/info')
def info():
    return jsonify({
        'python_version': os.popen('python --version').read().strip(),
        'flask_version': '2.3.0',
        'environment': os.getenv('ENVIRONMENT', 'production')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8001)
EOF

cat > ~/apps/flask-app/requirements.txt << 'EOF'
Flask==2.3.0
gunicorn==21.2.0
EOF

cat > ~/apps/flask-app/Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8001
CMD ["python", "app.py"]
EOF

echo "Creating Node.js Application..."
cat > ~/apps/nodejs-app/server.js << 'EOF'
const express = require('express');
const os = require('os');

const app = express();
const PORT = 8002;

app.get('/', (req, res) => {
    res.json({
        app: 'Node.js Microservice',
        version: '1.0.0',
        hostname: os.hostname(),
        message: 'Hello from Node.js!',
        status: 'running'
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.get('/info', (req, res) => {
    res.json({
        node_version: process.version,
        platform: process.platform,
        uptime: process.uptime()
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
EOF

cat > ~/apps/nodejs-app/package.json << 'EOF'
{
  "name": "nodejs-microservice",
  "version": "1.0.0",
  "description": "Node.js microservice for DevOps portfolio",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat > ~/apps/nodejs-app/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY server.js .
EXPOSE 8002
CMD ["npm", "start"]
EOF

echo "Creating Go Application..."
cat > ~/apps/go-app/main.go << 'EOF'
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"
    "runtime"
    "time"
)

type Response struct {
    App      string `json:"app"`
    Version  string `json:"version"`
    Hostname string `json:"hostname"`
    Message  string `json:"message"`
    Status   string `json:"status"`
}

type InfoResponse struct {
    GoVersion string `json:"go_version"`
    OS        string `json:"os"`
    Arch      string `json:"arch"`
    Uptime    string `json:"uptime"`
}

var startTime time.Time

func init() {
    startTime = time.Now()
}

func main() {
    http.HandleFunc("/", homeHandler)
    http.HandleFunc("/health", healthHandler)
    http.HandleFunc("/info", infoHandler)
    
    log.Println("Server starting on :8003")
    log.Fatal(http.ListenAndServe(":8003", nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
    hostname, _ := os.Hostname()
    resp := Response{
        App:      "Go Microservice",
        Version:  "1.0.0",
        Hostname: hostname,
        Message:  "Hello from Go!",
        Status:   "running",
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(resp)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
    uptime := time.Since(startTime).String()
    resp := InfoResponse{
        GoVersion: runtime.Version(),
        OS:        runtime.GOOS,
        Arch:      runtime.GOARCH,
        Uptime:    uptime,
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(resp)
}
EOF

cat > ~/apps/go-app/go.mod << 'EOF'
module go-microservice

go 1.21
EOF

cat > ~/apps/go-app/Dockerfile << 'EOF'
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod main.go ./
RUN go build -o server main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/server .
EXPOSE 8003
CMD ["./server"]
EOF

echo "Building Docker images..."
cd ~/apps/flask-app
docker build -t flask-app:latest .

cd ~/apps/nodejs-app
docker build -t nodejs-app:latest .

cd ~/apps/go-app
docker build -t go-app:latest .

echo "Deploying containers..."
docker run -d --name flask-app --restart=always -p 8001:8001 flask-app:latest
docker run -d --name nodejs-app --restart=always -p 8002:8002 nodejs-app:latest
docker run -d --name go-app --restart=always -p 8003:8003 go-app:latest

echo "Configuring Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/apps > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        return 200 'DevOps Portfolio - Microservices\n\nAvailable endpoints:\n/flask - Flask App\n/nodejs - Node.js App\n/go - Go App\n';
        add_header Content-Type text/plain;
    }
    
    location /flask {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /nodejs {
        proxy_pass http://localhost:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /go {
        proxy_pass http://localhost:8003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/apps /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# Wait for containers to start
sleep 5

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Deployed Applications:"
echo "  - Flask App:   http://$(curl -s ifconfig.me):8001"
echo "  - Node.js App: http://$(curl -s ifconfig.me):8002"
echo "  - Go App:      http://$(curl -s ifconfig.me):8003"
echo "  - Nginx:       http://$(curl -s ifconfig.me)"
echo ""
echo "Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Health Check:"
for port in 8001 8002 8003; do
    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health || echo "failed")
    echo "  Port $port: $status"
done
echo "=========================================="
