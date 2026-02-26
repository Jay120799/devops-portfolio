#!/bin/bash
# Run the AWS Cost Dashboard (Flask UI)
# Usage: ./run_dashboard.sh

cd "$(dirname "$0")/app"
pip install -q -r requirements.txt
echo "Open http://localhost:5000 (or http://<this-machine-IP>:5000)"
exec python app.py
