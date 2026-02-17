# Project 3: GitOps with ArgoCD and Advanced Alerting

## Instances Required: 2 x t3.micro (FREE TIER)

### Instance 1: GitOps Server
- K3s Kubernetes
- ArgoCD (GitOps controller)
- Multi-environment (dev/staging/prod namespaces)
- Auto-sync from Git

### Instance 2: Monitoring and Alerts
- Prometheus
- Grafana with Alert Rules
- Alertmanager (Slack/Email notifications)
- SPOG dashboards

---

## Architecture

Git Repository (Single Source of Truth)
  ├── Helm Charts
  ├── K8s Manifests  
  └── Environment Configs
      │
      ▼
┌─────────────────────────────────────────────────────────┐
│       Instance 1: GitOps Server (1GB RAM)              │
│  ┌──────────────────────────────────────────────────┐  │
│  │            ArgoCD                                 │  │
│  │  - Watches Git Repository                        │  │
│  │  - Auto-syncs changes to K8s                     │  │
│  │  - Self-healing deployments                      │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │      K8s Namespaces: dev / staging / prod       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│    Instance 2: Monitoring + Alerts (1GB RAM)           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Prometheus   │→│   Grafana    │→│Alertmanager  │ │
│  │  (Metrics)   │ │  (Dashboards)│ │ (Slack/Email)│ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Setup Instructions

### Deploy Instance 1 (GitOps)
```bash
cd instance-1-gitops
./setup.sh
```

### Deploy Instance 2 (Monitoring)
```bash
cd instance-2-monitoring
./setup.sh
```

---

## Access Services

- **ArgoCD UI:** http://INSTANCE1-IP:8080 (admin/get-password)
- **Grafana:** http://INSTANCE2-IP:3000 (admin/admin)
- **Prometheus:** http://INSTANCE2-IP:9090

---

## GitOps Workflow

1. Update Helm chart or K8s manifest in Git
2. Commit and push changes
3. ArgoCD detects changes automatically
4. ArgoCD syncs to Kubernetes cluster
5. New version deployed
6. Grafana alerts if issues detected

---

## Cost: $0.00 (6 hours per practice session)
