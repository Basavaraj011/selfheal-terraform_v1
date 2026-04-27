# Selfheal Deployment Setup

This document provides step-by-step instructions for setting up the **Selfheal** system on AWS with Docker and ECR.

---

## Prerequisites

- AWS account with VPC configured  
- AWS CLI installed and configured  
- Docker installed  
- Git installed  
- AWS VPN Client installed

---

## Networking Resources 

1. **vpc** - 1
2. **Public Subnet** – 1  
3. **Private Subnets** – 2  
4. **Route Tables**  
   - Public subnet route table: `0.0.0.0/0 -> Internet Gateway (IGW)`  
   - Private subnet route table: `0.0.0.0/0 -> NAT Gateway`  
Configure the above in the terraform.tfvars the run 
   ```bash
   terraform apply
---

## Docker Image Workflow

- Clone the repository:
   ```bash
  git clone git@github.com:Basavaraj011/error_handling_system_fork.git
- Or
   ```bash
   git clone [https://github.com/Baj011/error_system_fork.git](https://github.com/Basavaraj011/error_handling_system_fork.git)
- Build the Docker image:
   ```bash
   docker build -t selfheal .
- Authenticate Docker with AWS ECR:
   ```bash
   aws ecr get-login-password --region ap-south-1 \
   | docker login --username AWS --password-stdin 960451805606.dkr.ecr.ap-south-1.amazonaws.com
- Tag the Docker image:
   ```bash
   docker tag selfheal:latest 960451805606.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest

- Push the Docker image:
   ```bash
   docker push 960451805606.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest

## VPN Setup
- Note the VPN endpoint and update the .ovpn file.
- Download and install the AWS VPN Client if not already installed.

## Database Setup
- Note the DB endpoint and update environment variables.
- Connect to the DB using:
- Username: username
- Password: password
- Auth: SQL Server Auth
- Server Type: Database Engine
- Server Name: RDS Endpoint
- Create the required tables in the database.

## Teams Bot Configuration
- Replace the callback URL with the API Gateway invoke URL in the Teams bot configuration.

## Summary
This setup ensures:
- Proper networking with public and private subnets.
- Secure routing via IGW and NAT.
- Docker image built, tagged, and pushed to AWS ECR.
- Database connection established and tables created.
- VPN configured for secure access.
- Teams bot integrated with API Gateway.


