"""
AWS Cost Dashboard - Flask backend.
Runs the resource report script and parses output for UI.
"""
import os
import re
import subprocess
import glob
from pathlib import Path
from flask import Flask, render_template, jsonify, request

app = Flask(__name__)

# Paths relative to project root (parent of app/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
REPORTS_DIR = PROJECT_ROOT / "reports"
SCRIPT_PATH = SCRIPTS_DIR / "aws_daily_resource_report.sh"


def parse_report_file(filepath):
    """Parse report .txt and return structured data for UI."""
    data = {
        "generated": None,
        "ec2_instances": [],
        "ec2_total_usd_per_hr": "0",
        "ebs_volumes": [],
        "ebs_total_usd_per_hr": "0",
        "raw_error": None,
    }
    if not filepath or not os.path.isfile(filepath):
        return data

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # Generated line: "  Generated: 2025-02-20 12:00:00"
    m = re.search(r"Generated:\s*(\d{4}-\d{2}-\d{2}\s+\S+)", content)
    if m:
        data["generated"] = m.group(1).strip()

    # EC2 per-instance: "  i-0123abc  running  t3.micro       $0.0104/hr"
    ec2_pattern = re.compile(
        r"^\s+(i-\S+)\s+(running|stopped)\s+(\S+)\s+\$([\d.]+)/hr", re.MULTILINE
    )
    for m in ec2_pattern.finditer(content):
        data["ec2_instances"].append({
            "instance_id": m.group(1),
            "state": m.group(2),
            "instance_type": m.group(3),
            "usd_per_hr": m.group(4),
        })

    # EC2 total: "Est. total EC2 (running) $/hr: $0.0208"
    m = re.search(r"Est\. total EC2 \(running\) \$/hr:\s*\$?([\d.]+)", content)
    if m:
        data["ec2_total_usd_per_hr"] = m.group(1)

    # EBS per-volume: "  vol-abc  30 GB  in-use     $0.003288/hr"
    ebs_pattern = re.compile(
        r"^\s+(vol-\S+)\s+(\d+)\s+GB\s+(\S+)\s+\$([\d.]+)/hr", re.MULTILINE
    )
    for m in ebs_pattern.finditer(content):
        data["ebs_volumes"].append({
            "volume_id": m.group(1),
            "size_gb": int(m.group(2)),
            "state": m.group(3),
            "usd_per_hr": m.group(4),
        })

    # EBS total: "Total EBS est. $/hr: $0.0050"
    m = re.search(r"Total EBS est\. \$/hr:\s*\$?([\d.]+)", content)
    if m:
        data["ebs_total_usd_per_hr"] = m.group(1)

    return data


def get_latest_report():
    """Return path to most recent report file, or None."""
    pattern = str(REPORTS_DIR / "aws_resource_report_*.txt")
    files = glob.glob(pattern)
    if not files:
        return None
    return max(files, key=os.path.getmtime)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/data")
def api_data():
    """Return latest report data as JSON (without running script)."""
    report_path = get_latest_report()
    data = parse_report_file(report_path)
    data["report_file"] = os.path.basename(report_path) if report_path else None
    return jsonify(data)


@app.route("/api/run", methods=["POST", "GET"])
def api_run():
    """Run the report script, then return latest data as JSON."""
    if not SCRIPT_PATH.exists():
        return jsonify({"error": "Script not found", "path": str(SCRIPT_PATH)}), 500

    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    try:
        subprocess.run(
            ["bash", str(SCRIPT_PATH), str(REPORTS_DIR)],
            cwd=str(PROJECT_ROOT),
            capture_output=True,
            text=True,
            timeout=120,
        )
    except subprocess.TimeoutExpired:
        return jsonify({"error": "Script timed out"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    report_path = get_latest_report()
    data = parse_report_file(report_path)
    data["report_file"] = os.path.basename(report_path) if report_path else None
    return jsonify(data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
