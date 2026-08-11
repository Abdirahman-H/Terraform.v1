Overview

This project deploys a fully functional WordPress stack on AWS using Terraform. It includes all necessary networking, compute, and database resources following AWS best practices for security and high availability.

The project also includes two CI/CD pipelines built with GitHub Actions to automate deployment and destruction of the infrastructure, complete with manual approval gates.


Architecture

```
Internet → ALB → EC2 (WordPress) → RDS (MySQL)
↑
NAT Gateway
↑
Private Subnets (RDS)
```


Prerequisites


AWS Account
AWS CLI configured (`aws configure`)
Terraform installed
SSH Key Pair created in AWS (`eu-west-2`)



Project Structure

```
project/
├── backend/
│   ├── main.tf          # S3 bucket for remote state
│   └── providers.tf     # AWS provider configuration
└── infrastructure/
├── main.tf          # All AWS resources
├── providers.tf     # AWS provider + S3 backend
└── variables.tf     # Variable definitions
.github/
└── workflows/
├── terraform.yml          # Deploy pipeline
└── terraform-destroy.yml  # Destroy pipeline
```


How to Deploy

Step 1 — Create Remote State Backend

```bash
cd backend/
terraform init
terraform apply
```

Step 2 — Deploy WordPress Infrastructure

```bash
cd infrastructure/
terraform init
terraform apply
```

Step 3 — Install WordPress on EC2

```bash

SSH into EC2

ssh -i keypair-wordpress.pem ec2-user@<ec2-public-ip>

Install LAMP stack

sudo yum update -y
sudo yum install -y httpd php php-mysqlnd mariadb105
sudo systemctl start httpd
sudo systemctl enable httpd

Download WordPress

cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz
sudo chown -R apache:apache /var/www/html

Configure WordPress

sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php

Update DB_NAME, DB_USER, DB_PASSWORD, DB_HOST

```

Step 4 — Access WordPress


Visit your ALB DNS name in your browser:



```
http://<alb-dns-name>.eu-west-2.elb.amazonaws.com
```


CI/CD Pipeline

This project includes two GitHub Actions pipelines that automate the deployment and destruction of the WordPress infrastructure.

Deploy Pipeline


File: `terraform.yml`
Trigger: Automatic on push to `main` (Terraform files only)



Triggers automatically when Terraform files change inside `project/infrastructure/`. Requires manual approval before applying any changes to AWS.

```
Push Terraform changes to main
↓
Terraform Init     → connects to S3 remote state
Terraform Fmt      → validates code formatting
Terraform Validate → checks code is valid
Terraform Plan     → shows what will change in AWS
↓
Pipeline pauses for manual approval ⏸️
↓
Approve → Terraform Apply → infrastructure deployed ✅
Reject  → pipeline stops, nothing changes ✅
```

Destroy Pipeline


File: `terraform-destroy.yml`
Trigger: Manual only (`workflow_dispatch`)



Triggered manually only. Requires typing `DESTROY` to confirm and manual approval before destroying any infrastructure.

```
Manually trigger from GitHub Actions
↓
Type DESTROY to confirm
↓
Terraform Init          → connects to S3 remote state
Terraform Plan -destroy → shows what will be destroyed
↓
Pipeline pauses for manual approval ⏸️
↓
Approve → Terraform Destroy → infrastructure removed ✅
Reject  → pipeline stops, nothing changes ✅
```

Pipeline Features

FeatureDescriptionPath based triggersOnly runs when Terraform files changeRemote state in S3Consistent state across all pipeline runsState lockingPrevents concurrent applies corrupting stateSecrets managementAWS credentials stored in GitHub SecretsArtifact passingPlan file passed between jobs securelyManual approval gatesHuman review before any infrastructure changesSafety confirmationType `DESTROY` to prevent accidental destruction

GitHub Secrets Required

SecretDescription`AWS_ACCESS_KEY_ID`IAM user access key`AWS_SECRET_ACCESS_KEY`IAM user secret key`TF_VAR_db_password`RDS database password`TF_VAR_db_username`RDS database username


How to Destroy

Option 1 — Via Destroy Pipeline (Recommended)

```
GitHub Actions → Terraform Destroy → Run workflow → Type DESTROY → Approve
```

Option 2 — Locally

```bash

Destroy WordPress infrastructure

cd infrastructure/
terraform destroy

Destroy backend

cd backend/
terraform destroy
```


Technologies Used

TechnologyPurposeTerraformInfrastructure as CodeAWS VPCNetworkingAWS EC2WordPress web serverAWS RDSMySQL databaseAWS ALBLoad balancingAWS S3Remote state storageAWS NAT GatewayPrivate subnet internet accessAmazon Linux 2023Operating systemWordPressCMSGitHub ActionsCI/CD pipelinesGitHub EnvironmentsManual approval gates


Security


🔒 RDS in private subnet — not accessible from the internet
🔒 EC2 only accepts traffic from ALB — no direct public access
🔒 SSH restricted to a specific IP address
🔒 Sensitive values stored in GitHub Secrets — never hardcoded
🔒 Remote state stored securely in S3 with state locking enabled
🔒 Manual approval required before any infrastructure changes
🔒 Destroy pipeline requires explicit `DESTROY` confirmation