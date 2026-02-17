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

# Security Group for CI/CD Server
resource "aws_security_group" "cicd_sg" {
  name        = "devops-cicd-server-sg"
  description = "Security group for CI/CD server"
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "cicd-server-sg"
    Project = "devops-portfolio"
  }
}

# Security Group for App Server
resource "aws_security_group" "app_sg" {
  name        = "devops-app-server-sg"
  description = "Security group for application server"
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Application Ports"
    from_port   = 8001
    to_port     = 8003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "app-server-sg"
    Project = "devops-portfolio"
  }
}

# EC2 Instance for CI/CD
resource "aws_instance" "cicd_server" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              EOF
  
  tags = {
    Name = "cicd-server"
    Project = "devops-portfolio"
  }
}

# EC2 Instance for Apps
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              EOF
  
  tags = {
    Name = "app-server"
    Project = "devops-portfolio"
  }
}

output "cicd_server_ip" {
  description = "Public IP of CI/CD server"
  value       = aws_instance.cicd_server.public_ip
}

output "app_server_ip" {
  description = "Public IP of application server"
  value       = aws_instance.app_server.public_ip
}

output "ssh_cicd" {
  description = "SSH command for CI/CD server"
  value       = "ssh -i your-key.pem ubuntu@${aws_instance.cicd_server.public_ip}"
}

output "ssh_app" {
  description = "SSH command for app server"
  value       = "ssh -i your-key.pem ubuntu@${aws_instance.app_server.public_ip}"
}
