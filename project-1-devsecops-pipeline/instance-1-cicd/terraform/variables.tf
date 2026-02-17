variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 in us-east-1
  # Update this for your region:
  # us-west-2: ami-03f65b8614a860c29
  # eu-west-1: ami-0905a3c97561e0b69
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "devops-portfolio"
}
