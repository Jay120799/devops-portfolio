import json
import boto3
from datetime import datetime

# Lambda function: Cost Optimizer
# Analyzes resource usage and provides optimization recommendations

def lambda_handler(event, context):
    """
    Automated cost optimization for Kubernetes resources
    Triggered weekly
    """
    
    recommendations = []
    
    # Simulate resource analysis
    pods = [
        {'name': 'flask-app', 'cpu_usage': '20%', 'memory_usage': '150MB', 'requested': '500MB'},
        {'name': 'nodejs-app', 'cpu_usage': '15%', 'memory_usage': '100MB', 'requested': '512MB'},
        {'name': 'go-app', 'cpu_usage': '10%', 'memory_usage': '50MB', 'requested': '256MB'}
    ]
    
    for pod in pods:
        # Check if pod is over-provisioned
        memory_used = int(pod['memory_usage'].replace('MB', ''))
        memory_requested = int(pod['requested'].replace('MB', ''))
        
        if memory_used < (memory_requested * 0.5):
            recommendation = {
                'pod': pod['name'],
                'issue': 'Over-provisioned',
                'current_request': pod['requested'],
                'recommended_request': f"{memory_used * 2}MB",
                'potential_savings': f"{((memory_requested - memory_used * 2) / memory_requested) * 100:.1f}%"
            }
            recommendations.append(recommendation)
    
    # Save report to S3
    s3 = boto3.client('s3')
    report = {
        'timestamp': datetime.now().isoformat(),
        'recommendations': recommendations,
        'total_pods_analyzed': len(pods)
    }
    
    # s3.put_object(
    #     Bucket='YOUR-BUCKET',
    #     Key=f'cost-reports/{datetime.now().strftime("%Y-%m-%d")}.json',
    #     Body=json.dumps(report)
    # )
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Cost optimization analysis completed',
            'recommendations': recommendations
        })
    }
