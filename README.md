# WordPress on AWS with Terraform

## Overview
This project deploys a fully functional WordPress stack on AWS using Terraform. 
It includes all necessary networking, compute, and database resources following 
AWS best practices for security and high availability.

## Architecture
```
Internet → ALB → EC2 (WordPress) → RDS (MySQL)
                      ↑
                 NAT Gateway
                      ↑
              Private Subnets (RDS)
```

## Prerequisites
- AWS Account
- AWS CLI configured (`aws configure`)
- Terraform installed
- SSH Key Pair created in AWS (`eu-west-2`)

## Project Structure
```
project/
├── backend/
│   ├── main.tf          # S3 bucket for remote state
│   └── providers.tf     # AWS provider configuration
└── infrastructure/
    ├── main.tf          # All AWS resources
    ├── providers.tf     # AWS provider + S3 backend
    └── variables.tf     # Variable definitions
```

## How to Deploy

### Step 1 - Create Remote State Backend
```bash
cd backend/
terraform init
terraform apply
```

### Step 2 - Deploy WordPress Infrastructure
```bash
cd infrastructure/
terraform init
terraform apply
```

### Step 3 - Install WordPress on EC2
```bash
# SSH into EC2
ssh -i keypair-wordpress.pem ec2-user@

# Install LAMP stack
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd mariadb105
sudo systemctl start httpd
sudo systemctl enable httpd

# Download WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz
sudo chown -R apache:apache /var/www/html

# Configure WordPress
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php
# Update DB_NAME, DB_USER, DB_PASSWORD, DB_HOST
```

### Step 4 - Access WordPress
> Visit your ALB DNS name in your browser:
```
http://<alb-dns-name>.eu-west-2.elb.amazonaws.com
```

## How to Destroy
```bash
# Destroy WordPress infrastructure
cd infrastructure/
terraform destroy

# Destroy backend
cd backend/
terraform destroy
```

## Technologies Used
- **Terraform** — Infrastructure as Code
- **AWS VPC** — Networking
- **AWS EC2** — WordPress web server
- **AWS RDS** — MySQL database
- **AWS ALB** — Load balancing
- **AWS S3** — Remote state storage
- **AWS NAT Gateway** — Private subnet internet access
- **Amazon Linux 2023** — Operating system
- **WordPress** — CMS

## Security
- RDS in private subnet — not accessible from internet
- EC2 only accepts traffic from ALB
- SSH restricted to specific IP
- Sensitive values stored in `terraform.tfvars` (not pushed to GitHub)
- Remote state stored securely in S3