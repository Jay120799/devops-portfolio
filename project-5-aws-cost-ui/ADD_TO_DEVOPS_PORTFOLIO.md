# Add this project to your devops-portfolio repo (Option A)

Do this on your machine (where you have git and access to GitHub).

## Steps

### 1. Clone devops-portfolio (if you don’t have it yet)

```bash
git clone https://github.com/Jay120799/devops-portfolio.git
cd devops-portfolio
```

### 2. Copy project-5-aws-cost-ui into the repo

Copy the entire folder **project-5-aws-cost-ui** (this folder) into `devops-portfolio` so you have:

```
devops-portfolio/
├── docs/
├── project-1-devsecops-pipeline/
├── project-2-kubernetes-monitoring/
├── project-3-gitops-argocd/
├── project-4-security-serverless/
├── project-5-aws-cost-ui/    <-- add this
├── scripts/
├── README.md
└── ...
```

Example (from the folder that contains project-5-aws-cost-ui):

```bash
# Windows (PowerShell)
Copy-Item -Recurse project-5-aws-cost-ui C:\path\to\devops-portfolio\

# Or drag-and-drop the folder into devops-portfolio in File Explorer
```

### 3. Add, commit, and push

```bash
cd devops-portfolio
git add project-5-aws-cost-ui
git status
git commit -m "Add Project 5: AWS Cost per Hour UI dashboard"
git push origin main
```

### 4. (Optional) Update devops-portfolio README

In **devops-portfolio/README.md** you can add a row and section for Project 5, for example:

**Instance Requirements Summary table – add row:**

| **Project 5** | 1 x t3.micro (or local) | 1GB | 0.5 hour | 0–1 hour |

**Projects Overview – add section:**

```markdown
### Project 5: AWS Cost per Hour (UI Dashboard)

**Shell script + web UI to see EC2 and EBS cost per hour**

**Instances:** 1 x t3.micro (or run on any machine with AWS CLI)  
**Tools:** Bash, AWS CLI, Python, Flask

**Skills Demonstrated:**
* Cost visibility and reporting
* AWS CLI automation
* Simple web dashboard
* DevOps cost optimization
```

Done. The project will be at:  
**https://github.com/Jay120799/devops-portfolio/tree/main/project-5-aws-cost-ui**
