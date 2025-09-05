# Basic Terraform EC2 Deployment

This project demonstrates deploying a **basic EC2 instance on AWS** using Terraform. The goal was to learn how to provision cloud infrastructure with code.

## What the project does

- Launches a **t2.micro EC2 instance** (Free Tier eligible)
- Uses the **latest Amazon Linux 2023 (Kernel 6.1) AMI** retrieved automatically via **SSM Parameter Store**
- Outputs the **public IP address** after deployment

## How it was done

1. **Terraform provider** was set up to use AWS in the chosen region.
2. The latest AMI was dynamically fetched using a **Terraform data block**.
3. An **EC2 instance resource** was created with minimal configuration (instance type, key pair, and tags).
4. Terraform **outputs** were used to display the instance’s public IP after deployment.

This project focuses on keeping the configuration **simple, Free Tier eligible, and easily reproducible** for learning purposes.