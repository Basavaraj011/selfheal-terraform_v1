# Selfheal Deployment Setup

This document provides step-by-step instructions for setting up the **Selfheal** system on AWS using Docker, Amazon ECR, Terraform, and AWS Client VPN.

---

# Architecture

![Selfheal Architecture](images/gram.jpg

---

# Prerequisites

Ensure the following tools and resources are available before starting:

- AWS Account with required permissions
- AWS CLI installed and configured
- Terraform installed
- Docker installed
- Git installed
- AWS VPN Client installed
- Access to the Selfheal source repository

---

# Terraform Setup

## 1. Update `terraform.tfvars`

Configure the required variables:

```hcl
region = "us-east-1"

image_url = "<ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest"

db_username = "<admin-username>"
db_password = "<admin-password>"

server_cert_path = "./certs/server.crt"
server_key_path  = "./certs/server.key"
ca_cert_path     = "./certs/ca.crt"
ca_key_path      = "./certs/ca.key"

bucket_name = "self-healing-system-dgs"
```

---

## 2. Configure Secrets Manager

Add the required application secrets in the Secrets Manager module configuration before deployment.

---

## 3. Generate VPN Certificates (Optional)

If new VPN certificates are required, generate them using the following script:

```bash
#!/bin/bash

mkdir -p certs
cd certs

openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/CN=SelfhealVPN-CA"

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=selfheal-vpn-server"

openssl x509 \
  -req \
  -in server.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out server.crt \
  -days 365

rm server.csr
```

### Download VPN Configuration

1. Open the AWS Console.
2. Navigate to **EC2 → Client VPN Endpoints**.
3. Select the appropriate VPN endpoint.
4. Click **Download Client Configuration**.
5. Save the file as:

```text
client-vpn.ovpn
```

---

## 4. Configure AWS VPN Client

Follow the instructions provided in:

```text
AWS_VPN_Client_setup.pdf
```

---

## 5. Deploy Infrastructure

Initialize Terraform:

```bash
terraform init
```

Deploy the infrastructure:

```bash
terraform apply
```

When prompted, enter:

```text
yes
```

---

# Docker Image Workflow

## Clone the Repository

Using SSH:

```bash
git clone git@github.com:Basavaraj011/error_handling_system.git
```

Or using HTTPS:

```bash
git clone https://github.com/Basavaraj011/error_handling_system_fork.git
```

Navigate to the project directory:

```bash
cd error_handling_system
```

---

## Build the Docker Image

```bash
docker build -t selfheal .
```

---

## Authenticate Docker with Amazon ECR

```bash
aws ecr get-login-password --region ap-south-1 \
| docker login --username AWS --password-stdin <ACCOUNT>.dkr.ecr.ap-south-1.amazonaws.com
```

---

## Tag the Docker Image

```bash
docker tag selfheal:latest <ACCOUNT>.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest
```

---

## Push the Docker Image

```bash
docker push <ACCOUNT>.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest
```

---

# VPN Setup

After Terraform deployment:

1. Note the Client VPN endpoint.
2. Update the downloaded `.ovpn` configuration file if required.
3. Open AWS VPN Client.
4. Import the `.ovpn` configuration.
5. Connect to the VPN before accessing internal resources.

---

# Database Setup

After RDS deployment:

1. Note the RDS endpoint.
2. Update the application environment variables with the database endpoint.
3. Connect using SQL Server Management Studio (SSMS) or a compatible client.

Connection Details:

```text
Server Type : Database Engine
Server Name : <RDS Endpoint>
Authentication : SQL Server Authentication
Username : <db_username>
Password : <db_password>
```

4. Create the required application tables and schema.

---

# Teams Bot Configuration

Update the Teams Bot callback endpoint with the deployed API Gateway URL.

Example:

```text
https://<api-id>.execute-api.<region>.amazonaws.com/prod/
```

Ensure the callback URL points to the API Gateway endpoint exposed by the Selfheal application.

---

# Verification Checklist

Verify the following after deployment:

- [ ] Terraform deployment completed successfully
- [ ] VPN connection is working
- [ ] ECS services are running
- [ ] Docker image is available in ECR
- [ ] RDS instance is reachable through VPN
- [ ] Secrets are available in AWS Secrets Manager
- [ ] API Gateway endpoint is accessible
- [ ] Teams Bot callback URL is updated
- [ ] Application logs are visible in CloudWatch

---

# Summary

This deployment provides:

- Secure AWS networking using public and private subnets
- Outbound connectivity through NAT Gateway
- Containerized deployment using Docker and ECS Fargate
- Image storage using Amazon ECR
- Secure secret management with AWS Secrets Manager
- Private database access through AWS Client VPN
- Application monitoring through Amazon CloudWatch
- Microsoft Teams integration through API Gateway
- Infrastructure provisioning using Terraform
