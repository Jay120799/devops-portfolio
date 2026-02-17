# Project 2: Kubernetes with Monitoring Stack

## Instances Required: 2 x t3.micro (FREE TIER)

### Instance 1: Kubernetes Cluster
- K3s (lightweight Kubernetes)
- Helm (package manager)
- 3 Microservices (in pods)
- Ingress Controller

### Instance 2: Monitoring Stack
- Prometheus (metrics collection)
- Grafana (visualization SPOG)
- Node Exporter (system metrics)
- Alertmanager (alerts)

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│      Instance 1: Kubernetes Cluster (1GB RAM)          │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │           K3s Kubernetes Cluster                 │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │  │
│  │  │Flask Pod │  │Node.js   │  │  Go Pod  │      │  │
│  │  │          │  │  Pod     │  │          │      │  │
│  │  └──────────┘  └──────────┘  └──────────┘      │  │
│  │                                                  │  │
│  │  ┌────────────────────────────────┐            │  │
│  │  │  Ingress Controller (Traefik)  │            │  │
│  │  └────────────────────────────────┘            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                      │
                      │ Scrapes metrics
                      ▼
┌─────────────────────────────────────────────────────────┐
│    Instance 2: Monitoring Stack (1GB RAM)              │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Prometheus   │  │   Grafana    │  │Alertmanager  │ │
│  │    :9090     │  │     :3000    │  │    :9093     │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                         │
│  ┌────────────────────────────────────────────────┐   │
│  │       Grafana SPOG Dashboards                  │   │
│  │  - Kubernetes Cluster Overview                 │   │
│  │  - Pod Metrics                                 │   │
│  │  - Application Performance                     │   │
│  └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Setup Instructions

### Deploy Instance 1 (K8s Cluster)

```bash
cd instance-1-k8s
./setup.sh
```

### Deploy Instance 2 (Monitoring)

```bash
cd instance-2-monitoring
./setup.sh
```

---

## Access Services

- **K8s API:** https://INSTANCE1-IP:6443
- **Prometheus:** http://INSTANCE2-IP:9090
- **Grafana:** http://INSTANCE2-IP:3000 (admin/admin)
- **Applications:** http://INSTANCE1-IP

---

## Technologies

- **K3s** - Lightweight Kubernetes
- **Helm** - Package manager
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Node Exporter** - System metrics
- **Kube-State-Metrics** - K8s metrics
- **Alertmanager** - Alert routing

---

## Cost: $0.00 (6 hours per practice session)
