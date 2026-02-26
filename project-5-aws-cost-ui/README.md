# AWS Cost per Hour – UI Dashboard

**Shell script + web UI** to see **estimated AWS cost per hour** for EC2 instances and EBS volumes on any account where you run it. Use on your EC2 instance (or laptop with AWS CLI) to quickly check **how much you're spending per hour**.

- **Script:** `scripts/aws_daily_resource_report.sh` — runs AWS CLI, writes a report with $/hr per resource.
- **UI:** Flask app that runs the script and shows results in a **dashboard** (EC2 $/hr, EBS $/hr, tables).

---

## Quick start (on EC2 or any Linux with AWS CLI)

### 1. Clone (or copy this folder into your repo)

```bash
# This project lives in devops-portfolio as Project 5:
git clone https://github.com/Jay120799/devops-portfolio.git
cd devops-portfolio/project-5-aws-cost-ui

# Or clone a standalone repo (after you create it):
# git clone https://github.com/YOUR_USERNAME/aws-cost-ui.git
# cd aws-cost-ui
```

### 2. Configure AWS CLI (if not already)

```bash
aws configure
# Enter Access Key, Secret Key, region (e.g. us-east-1)
```

### 3. Make the script executable

```bash
chmod +x scripts/aws_daily_resource_report.sh
```

### 4. Install Python and run the dashboard

```bash
cd app
pip install -r requirements.txt
python app.py
```

### 5. Open the UI

- On the same machine: **http://localhost:5000**
- From another machine (e.g. your PC): **http://&lt;EC2-public-IP&gt;:5000**  
  (Ensure EC2 security group allows inbound **5000** if needed.)

---

## Using the UI

| Action | What it does |
|--------|----------------|
| **Run report & refresh** | Runs the shell script (AWS CLI), then shows EC2 and EBS costs in the dashboard. |
| **Load latest report** | Loads the most recent report file without running the script. |

You’ll see:

- **EC2 total $/hr** — sum of running instances (approximate us-east-1 Linux on-demand).
- **EBS total $/hr** — sum of all volumes (gp3-like rate).
- **Combined $/hr** — EC2 + EBS.
- **Tables** — per-instance and per-volume $/hr.

---

## Run only the script (no UI)

On any EC2 or machine with AWS CLI:

```bash
./scripts/aws_daily_resource_report.sh          # report in current directory
./scripts/aws_daily_resource_report.sh /path   # report in /path
```

Report file: `aws_resource_report_YYYY-MM-DD.txt` (and same path is used by the UI when you click “Run report”).

---

## Add as a new GitHub repository

1. **Create a new repo** on GitHub (e.g. `aws-cost-ui` or `aws-cost-dashboard`).
2. **Push this project** (from your devops-portfolio clone or copy):

   ```bash
   cd project-5-aws-cost-ui
   git init
   git add .
   git commit -m "AWS Cost per Hour - script + UI dashboard"
   git remote add origin https://github.com/YOUR_USERNAME/aws-cost-ui.git
   git branch -M main
   git push -u origin main
   ```

3. **On any EC2** where you want to see cost per hour:

   ```bash
   git clone https://github.com/YOUR_USERNAME/aws-cost-ui.git
   cd aws-cost-ui
   chmod +x scripts/aws_daily_resource_report.sh
   cd app && pip install -r requirements.txt && python app.py
   ```

   Then open **http://&lt;EC2-IP&gt;:5000** and click **Run report & refresh** to see cost per hour on the UI.

---

## Cost note

- Estimates are **approximate** (us-east-1 Linux on-demand for EC2; gp3-like for EBS).
- For other regions or instance types not in the script’s list, extend `get_ec2_hourly_usd` in `scripts/aws_daily_resource_report.sh`.

---

## Structure

```
project-5-aws-cost-ui/
├── scripts/
│   └── aws_daily_resource_report.sh   # AWS CLI report with $/hr
├── app/
│   ├── app.py                         # Flask backend (run script, parse report)
│   ├── requirements.txt
│   └── templates/
│       └── index.html                 # Dashboard UI
├── reports/                           # Report files (created when script runs)
└── README.md
```
