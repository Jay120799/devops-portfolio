import json
import boto3
import subprocess
from datetime import datetime

# Lambda function: Security Scanner
# Scans Docker images for vulnerabilities using Trivy

def lambda_handler(event, context):
    """
    Automated security scanning for container images
    Triggered by CloudWatch Events (every 6 hours)
    """
    
    images_to_scan = [
        'flask-app:latest',
        'nodejs-app:latest',
        'go-app:latest'
    ]
    
    scan_results = []
    
    for image in images_to_scan:
        print(f"Scanning {image}...")
        
        # Simulate Trivy scan (in real deployment, call EC2 or ECS to run Trivy)
        result = {
            'image': image,
            'scan_time': datetime.now().isoformat(),
            'vulnerabilities': {
                'critical': 0,
                'high': 2,
                'medium': 5,
                'low': 10
            },
            'status': 'scanned'
        }
        
        scan_results.append(result)
        
        # Send alert if critical vulnerabilities found
        if result['vulnerabilities']['critical'] > 0:
            send_alert(image, result['vulnerabilities']['critical'])
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Security scan completed',
            'results': scan_results
        })
    }

def send_alert(image, critical_count):
    """Send SNS alert for critical vulnerabilities"""
    sns = boto3.client('sns')
    message = f"CRITICAL: {critical_count} critical vulnerabilities found in {image}"
    # sns.publish(TopicArn='YOUR-SNS-TOPIC', Message=message)
    print(f"Alert: {message}")
