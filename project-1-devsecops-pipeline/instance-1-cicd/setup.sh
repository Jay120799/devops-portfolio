#!/bin/bash
set -e

echo "=========================================="
echo "Setting up CI/CD Server (Instance 1)"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

# Install Java for Jenkins
echo "Installing Java..."
sudo apt-get install -y openjdk-11-jdk

# Install Jenkins
echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Ansible
echo "Installing Ansible..."
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install -y ansible

# Install Terraform
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

# Install additional tools
echo "Installing additional tools..."
sudo apt-get install -y curl wget vim htop

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Installed Software:"
echo "  - Docker: $(docker --version)"
echo "  - Jenkins: $(jenkins --version 2>/dev/null || echo 'Installed')"
echo "  - Ansible: $(ansible --version | head -1)"
echo "  - Terraform: $(terraform --version | head -1)"
echo "  - Git: $(git --version)"
echo ""
echo "Access Jenkins:"
echo "  URL: http://$(curl -s ifconfig.me):8080"
echo "  Initial Password:"
echo "    sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "Note: You may need to logout and login for Docker permissions"
echo "=========================================="
