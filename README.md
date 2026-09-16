# Selfheal Deployment Setup

This document provides step-by-step instructions for setting up the **Selfheal** system on AWS with Docker and ECR.
---

## Architecture

![alt text](images/SelfHeal_Architecture_Diagram.jpg)

---

## Prerequisites

- AWS account with VPC configured  
- AWS CLI installed and configured  
- Docker installed  
- Git installed  
- AWS VPN Client installed

---

## Terraform setup

1. Update the terraform.tfvars
	region                                = "us-east-1"

	image_url                             = "<ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest"


	db_username                           = username of choice (admin username)
	db_password                           = password of choice (admin password)


	server_cert_path                      = "./certs/server.crt" (You can generate using VPN certs step )
	server_key_path                       = "./certs/server.key"
	ca_cert_path                          = "./certs/ca.crt"
	ca_key_path                           = "./certs/ca.key"

	bucket_name                           = "self-healing-system-dgs" 
	

2. Add the secrets in secretsManager module in main.tfvars
3. VPN certs (Steps to generate if new certs required)
	#!/bin/bash
	mkdir -p certs
	cd certs
	openssl genrsa -out ca.key 2048
	openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/CN=SelfhealVPN-CA"
	openssl genrsa -out server.key 2048
	openssl req -new -key server.key -out server.csr -subj "/CN=selfheal-vpn-server"
	openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
	rm server.csr

	Download .ovpn
    - Go to AWS Console
	- EC2 → Client VPN Endpoints
	- Select respective vpn
	- Click "Download client configuration"
	- Save as client-vpn.ovpn
	
4. Next VPN setup :
	Follow the steps in "resources/AWS_VPN_Client_setup.pdf"

- Configure the above in the terraform.tfvars the run 
   ```bash
   terraform init
   ```
   ```bash
   terraform apply
---

## Docker Image Workflow (It is automated through CICD, no manual push needed)

- Clone the repository:
   ```bash
  git clone [git@github.com:Basavaraj011/error_handling_system.git](https://github.com/darshita-singh/error_handling_system.git)
- Or
   ```bash
   git clone git@github.com:darshita-singh/error_handling_system.git
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
## CICD for Selfheal Image push to AWS ECR 
- Developer creates the PR in the error_handling_system
- Upon PR merge to main, The git action "error_handling_system/.github/workflows/ecr-push.yml" is set to trigger (currently its adhoc) https://github.com/darshita-singh/error_handling_system/actions/workflows/ecr-push.yml
- The git action builds the docker image of the app "error_handling_system" and with the tag "latest" and pushes to ECR.
- The ECS pulls the latest image from the ECR whenever the ECS tasks gets triggered.

## Chatbot Setup
- Create a teams channel in MS teams.
- Create an outgoing webhook:
	1. Go to manage teams
	2. Go to apps
	3. Click "Create an outgoing webhook"
	4. Enter the name for the Chatbot
	5. Enter the callback URL (Can be found in the API Gatweway in AWS as invoke URL).
	6. Give a description
	7. Then create
	8. Then copy the HMAC secuity code and configure it in the env.
- Now find the channel_id (ex-> "19:FOGIzcqVPQTu8NIkau4RjeQTurx59OrP0wYLRk4xF241@thread.tacv2") from the channel link (Can find the link in "copy link" from the channel) and configure the channel name in the teams.yml in the error_handling_system repo.
- Now go to the channel and ask question to chatbot by invoking like, @chatbot-name "Your Question"

## VPN Setup
- Note the VPN endpoint from AWS Client VPN and update the .ovpn file.
- Download .ovpn
    1. Go to AWS Console
	2. EC2 → Client VPN Endpoints
	3. Select respective vpn
	4. Click "Download client configuration"
	5. Save as client-vpn.ovpn
- Download and install the AWS VPN Client if not already installed.
- Refer ![VPN Setup](resources/AWS_VPN_Client_setup.pdf)

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
