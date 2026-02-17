terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "devops-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function: Security Scanner
resource "aws_lambda_function" "security_scanner" {
  filename      = "security-scanner.zip"
  function_name = "k8s-security-scanner"
  role          = aws_iam_role.lambda_role.arn
  handler       = "security-scanner.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }
}

# Lambda Function: Cost Optimizer
resource "aws_lambda_function" "cost_optimizer" {
  filename      = "cost-optimizer.zip"
  function_name = "k8s-cost-optimizer"
  role          = aws_iam_role.lambda_role.arn
  handler       = "cost-optimizer.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
}

# CloudWatch Event Rule (Schedule)
resource "aws_cloudwatch_event_rule" "security_scan_schedule" {
  name                = "security-scan-every-6-hours"
  description         = "Trigger security scan every 6 hours"
  schedule_expression = "rate(6 hours)"
}

resource "aws_cloudwatch_event_target" "security_scan_target" {
  rule      = aws_cloudwatch_event_rule.security_scan_schedule.name
  target_id = "SecurityScannerLambda"
  arn       = aws_lambda_function.security_scanner.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_security" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_scanner.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_scan_schedule.arn
}

# S3 Bucket for reports
resource "aws_s3_bucket" "reports" {
  bucket = "devops-portfolio-reports-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

output "security_scanner_arn" {
  value = aws_lambda_function.security_scanner.arn
}

output "cost_optimizer_arn" {
  value = aws_lambda_function.cost_optimizer.arn
}

output "reports_bucket" {
  value = aws_s3_bucket.reports.id
}
