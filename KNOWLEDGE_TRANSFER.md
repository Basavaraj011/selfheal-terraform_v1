# Selfheal Terraform Infrastructure - Knowledge Transfer Documentation

**Last Updated:** August 10, 2026  
**Prepared For:** Team Members  
**Repository:** [selfheal-terraform_v1](https://github.com/Basavaraj011/selfheal-terraform_v1)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Architecture Overview](#architecture-overview)
4. [Key Components](#key-components)
5. [Network Layer (Latest Changes - PR #1)](#network-layer-latest-changes)
6. [Module Deep Dive](#module-deep-dive)
7. [Configuration & Deployment](#configuration--deployment)
8. [Important Changes in Recent PRs](#important-changes-in-recent-prs)
9. [Common Tasks & Troubleshooting](#common-tasks--troubleshooting)
10. [Useful Commands](#useful-commands)

---

## Project Overview

**Selfheal** is an AWS-based, containerized error handling and recovery system that leverages Terraform for Infrastructure as Code (IaC). The system is designed to:

- **Monitor errors** from multiple sources (S3, GitHub webhooks, etc.)
- **Process error logs** using ECS (Elastic Container Service)
- **Trigger automated recovery** via Lambda functions
- **Provide secure access** through VPN and API Gateway
- **Store data** in RDS
- **Integrate with external systems** (GitHub, Jira, Teams, Bitbucket etc)

**Technology Stack:**
- **Language:** Terraform (HCL) + Python (for Lambda handlers)
- **Cloud Platform:** AWS
- **Container Runtime:** Docker + ECS Fargate
- **Repository:** Docker images stored in AWS ECR
- **Database:** AWS RDS (SQL Server)

---

## Repository Structure

```
selfheal-terraform_v1/
├── main.tf                          # Root module - orchestrates all modules
├── variables.tf                     # Root-level input variables
├── locals.tf                        # Local values for reuse
├── terraform.tfvars                 # Terraform configuration values (region, credentials, etc.)
├── providers.tf                     # AWS provider configuration
├── KNOWLEDGE_TRANSFER.md            # This file
├── README.md                        # Basic setup instructions
│
├── modules/
│   ├── vpc/                         # VPC module (networking foundation)
│   │   ├── vpc.tf                   # VPC and subnet configuration
│   │   └── outputs.tf               # VPC outputs (IDs, CIDRs)
│   │
│   ├── security/                    # Security groups & network policies
│   │   ├── alb-sg.tf                # ALB security group
│   │   ├── ecs-sg.tf                # ECS security group
│   │   ├── rds-sg.tf                # RDS security group
│   │   └── variables.tf             # Security group variables
│   │
│   ├── ecs/                         # ECS cluster & task definitions
│   │   ├── cluster.tf               # ECS cluster
│   │   ├── service.tf               # ECS service configuration
│   │   ├── task-definition.tf       # Container task definition
│   │   └── variables.tf             # ECS variables
│   │
│   ├── alb/                         # Application Load Balancer
│   │   ├── main.tf                  # ALB configuration
│   │   ├── listener.tf              # ALB listener rules
│   │   └── variables.tf             # ALB variables
│   │
│   ├── lambda/                      # Lambda functions
│   │   ├── main.tf                  # Lambda function definitions
│   │   ├── handler.py               # S3 trigger handler
│   │   ├── handler_post_pr_actions.py  # GitHub PR event handler
│   │   ├── handler_selfheal_retry.py   # Retry mechanism handler
│   │   └── variables.tf             # Lambda variables
│   │
│   ├── iam/                         # IAM roles & policies
│   │   ├── execution-role.tf        # ECS execution role
│   │   ├── task-role.tf             # ECS task role
│   │   ├── github-oidc.tf           # GitHub Actions OIDC provider
│   │   ├── github-role.tf           # GitHub Actions IAM role
│   │   ├── post_pr_actions.tf       # Post-PR action IAM user
│   │   └── variables.tf             # IAM variables
│   │
│   ├── rds/                         # RDS database
│   │   ├── main.tf                  # RDS instance configuration
│   │   └── variables.tf             # RDS variables
│   │
│   ├── client_vpn/                  # Client VPN endpoint
│   │   ├── main.tf                  # Client VPN configuration
│   │   └── variables.tf             # VPN variables
│   │
│   ├── apigw/                       # API Gateway
│   │   ├── main.tf                  # API Gateway configuration
│   │   └── variables.tf             # API Gateway variables
│   │
│   ├── s3/                          # S3 bucket for error logs
│   │   ├── main.tf                  # S3 bucket configuration
│   │   └── variables.tf             # S3 variables
│   │
│   ├── ecr/                         # Elastic Container Registry
│   │   ├── main.tf                  # ECR repository
│   │   └── variables.tf             # ECR variables
│   │
│   └── permissions/                 # IAM permissions/policies
│       ├── policy.tf                # Inline policies for roles
│       └── variables.tf             # Permission variables
│
└── certs/                           # VPN certificates (not in repo, created locally)
    ├── server.crt
    ├── server.key
    ├── ca.crt
    └── ca.key
```

---

## Architecture Overview

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS VPC (10.90.64.128/25)              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Public Subnet (1)                      │  │
│  │               10.90.64.128/27 (us-east-1a)               │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Internet Gateway (IGW)                            │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│          ┌────────────────┴────────────────┐                   │
��          │                                 │                   │
│  ┌───────▼─────────────────┐  ┌───────────▼─────────────────┐ │
│  │  Private Subnet 1       │  │  Private Subnet 2           │ │
│  │  10.90.64.160/27        │  │  10.90.64.192/27            │ │
│  │  (us-east-1b)           │  │  (us-east-1b)               │ │
│  │                         │  │                             │ │
│  │  ┌─────────────────┐    │  │  ┌─────────────────┐        │ │
│  │  │ ECS Fargate     │    │  │  │ RDS (Primary)   │        │ │
│  │  │ Cluster         │    │  │  │ Database        │        │ │
│  │  │                 │    │  │  │                 │        │ │
│  │  │ Tasks:          │    │  │  │ SQL Server      │        │ │
│  │  │ • Selfheal App  │    │  │  │ Port: 1433      │        │ │
│  │  └─────────────────┘    │  │  └─────────────────┘        │ │
│  │                         │  │                             │ │
│  │  ┌─────────────────┐    │  │                             │ │
│  │  │ ALB             │    │  │                             │ │
│  │  │ Port: 3978      │    │  │                             │ │
│  │  └─────────────────┘    │  │                             │ │
│  └───────┬─────────────────┘  └─────────────────────────────┘ │
│          │                                                     │
│  ┌───────▼─────────────────────────────────────────────────┐  │
│  │              NAT Gateway (in Public Subnet)             │  │
│  │  (provides outbound internet access for private subnets)   │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         │                          │
         │                          │
    ┌────▼──────┐            ┌──────▼─────┐
    │ Lambda      │            │ S3 Bucket  │
    │ Functions   │            │ (Error     │
    │             │            │  Logs)     │
    │ • S3→ECS    │            │            │
    │ • PR Action │            │ Trigger:   │
    │ • Retry     │            │ Lambda →   │
    └─────────────┘            │ ECS Tasks  │
         │                      └────────────┘
         │
    ┌────▼──────────────────┐
    │ API Gateway            │
    │ (VPC Link Integration) │
    │ Endpoint for Teams Bot │
    └────────────────────────┘
```

### Data Flow

1. **S3 Event Trigger:**
   - Error log uploaded to S3 → S3 Event Notification
   - Lambda (`handler.py`) triggered
   - Lambda invokes ECS task with error log details
   - ECS task processes the error

2. **GitHub PR Event:**
   - GitHub Actions workflow sends PR event
   - Lambda (`handler_post_pr_actions.py`) receives event
   - ECS task processes PR-related actions

3. **Retry Mechanism:**
   - Lambda (`handler_selfheal_retry.py`) handles retries
   - ECS task executes with `RETRY` mode

---

## Key Components

### 1. **VPC Module** (`modules/vpc/`)
**Purpose:** Sets up the network foundation

**What it does:**
- Creates a VPC with CIDR block `10.90.64.128/25`
- Creates 1 public subnet (for NAT Gateway)
- Creates 2 private subnets (for ECS, RDS, etc.)
- Sets up Internet Gateway (IGW) for public subnet
- Creates NAT Gateway for private subnet outbound access
- Configures route tables for public and private subnets

**Key Outputs:**
- `vpc_id`: VPC identifier
- `vpc_cidr_block`: VPC CIDR block
- `public_subnets`: List of public subnet IDs
- `private_subnets`: List of private subnet IDs

**Usage in main.tf:**
```hcl
module "vpc" {
  source = "./modules/vpc"
}
# Later used as: module.vpc.vpc_id, module.vpc.private_subnets, etc.
```

---

### 2. **Security Module** (`modules/security/`)
**Purpose:** Creates security groups and network policies

**Security Groups Created:**
- **ALB Security Group:** Allows inbound traffic from VPC
- **ECS Security Group:** Allows traffic from ALB
- **RDS Security Group:** Allows traffic from ECS security group

**Key Files:**
- `alb-sg.tf`: Application Load Balancer security group
- `ecs-sg.tf`: ECS task security group
- `rds-sg.tf`: RDS database security group

---

### 3. **ECS Module** (`modules/ecs/`)
**Purpose:** Manages the containerized application

**Components:**
- **Cluster:** Named "selfheal-cluster"
- **Service:** Runs on Fargate with desired count 1
- **Task Definition:** Specifies container image, port (3978), CPU, Memory (512)
- **Environment Variables:** MODE=SERVICE for Chatbot service, MODE=PR_EVENT for post PR actions, MODE=RETRY for Selfheal retry, 

**Key Details:**
- Runs Docker image from ECR
- Uses IAM roles for permissions
- Executes in private subnets for security
- Health checks enabled via ALB

---

### 4. **Lambda Module** (`modules/lambda/`)
**Purpose:** Serverless compute for event-driven triggers

**Lambda Functions:**

| Function Name | Handler | Trigger | Purpose |
|---|---|---|---|
| `s3-to-ecs-trigger` | `handler.lambda_handler` | S3 ObjectCreated events | Processes error logs from S3 |
| `post-pr-actions-trigger` | `handler_post_pr_actions.lambda_handler` | GitHub PR webhook | Handles GitHub PR events |
| `selfheal_retry` | `handler_selfheal_retry.lambda_handler` | GitHub Retry trigger | Retries failed fix |

**Handler Logic (Python):**
- Parses incoming events
- Extracts relevant data (bucket, key, tenant_id, etc.)
- Launches ECS tasks with environment variables
- Returns task ARN for tracking

---

### 5. **IAM Module** (`modules/iam/`)
**Purpose:** Access control and authentication

**Roles Created:**
- **ECS Execution Role:** Allows ECS to pull images from ECR, access secrets
- **ECS Task Role:** Allows container to access AWS resources (S3, Secrets Manager, RDS)
- **Lambda Role:** Allows Lambda to invoke ECS tasks
- **GitHub Actions Role:** OIDC-based role for GitHub Actions CI/CD

**Key Policies:**
- `secretsmanager:GetSecretValue`: Access to secrets
- `ecr:GetAuthorizationToken`, `ecr:PutImage`: ECR operations
- `ecs:RunTask`: Lambda can invoke ECS tasks
- `kms:Decrypt`: Decrypt KMS-encrypted secrets

---

### 6. **RDS Module** (`modules/rds/`)
**Purpose:** Managed SQL Server database

**Configuration:**
- **Engine:** SQL Server
- **Instance Class:** db.t3.micro (can be scaled)
- **Storage:** 20 GB (default)
- **MultiAZ:** Enabled for high availability
- **Backup:** Automated daily backups

**Connection Details:**
- **Username:** Configured in `terraform.tfvars`
- **Database Name:** AI_PredictiveRecoveryDB
- **Port:** 1433 (SQL Server default)

---

### 7. **Client VPN Module** (`modules/client_vpn/`)
**Purpose:** Secure remote access to VPC resources

**Features:**
- Uses certificate-based authentication
- Allows developers to access private resources (RDS)
- Split tunneling enabled (only VPC traffic goes through VPN)
- UDP protocol on port 443

**Certificates Required:**
- Server certificate and key
- CA certificate and key
- Must be generated locally and stored in `certs/` directory

---

### 8. **API Gateway Module** (`modules/apigw/`)
**Purpose:** Public interface for Teams Bot and webhooks

**Configuration:**
- VPC Link integration with ALB
- Endpoints for receiving GitHub webhooks
- Teams Bot callback URL

---

### 9. **S3 Module** (`modules/s3/`)
**Purpose:** Storage for error logs and tenant data

**Bucket Structure:**
```
tenants/
├── tenant_a/
│   ├── config/          (configuration files)
│   ├── incoming/        (new error logs)
│   └── archive/         (processed logs)
```

**S3 Events:**
- ObjectCreated events trigger Lambda
- Lambda processes and launches ECS tasks

---

### 10. **ECR Module** (`modules/ecr/`)
**Purpose:** Docker image repository

**Repository:** `selfheal` (public by default, should be private)

**Docker Image Workflow:**
1. Build image locally: `docker build -t selfheal .`
2. Tag image: `docker tag selfheal:latest <ACCOUNT>.dkr.ecr.<REGION>.amazonaws.com/selfheal:latest`
3. Push to ECR: `docker push <ACCOUNT>.dkr.ecr.<REGION>.amazonaws.com/selfheal:latest`
4. ECS pulls image and runs task

---

## Network Layer (Latest Changes - PR #1)

### Overview of PR #1: "Network layer"
**Merged:** August 10, 2026  
**Commits:** 4 commits (586 additions, 328 deletions, 27 files changed)

### Major Changes

#### 1. **VPC Module Creation** ✅
**What Changed:** Introduced a dedicated VPC module to manage all networking resources

**Before:**
- VPC and subnets were hardcoded via variables
- Developers had to manually create VPC in AWS and reference in terraform.tfvars
- Variables like `vpc_id`, `vpc_cidr`, `existing_private_subnet_ids`, etc.

**After:**
- VPC module created: `modules/vpc/vpc.tf`
- Terraform now creates VPC, subnets, IGW, NAT Gateway, route tables automatically
- Simplified `terraform.tfvars` - no need for manual subnet IDs
- **New CIDR:** `10.90.64.128/25`
- **Public Subnet:** 1 subnet in us-east-1a (`10.90.64.128/27`)
- **Private Subnets:** 2 subnets in us-east-1a and us-east-1b (`10.90.64.160/27`, `10.90.64.192/27`)

**Key Files:**
- `modules/vpc/vpc.tf`: VPC and subnet configuration using terraform-aws-modules/vpc
- `modules/vpc/outputs.tf`: Exports VPC ID, CIDR block, subnet IDs

**Benefits:**
- Infrastructure fully automated - no manual AWS console steps
- Repeatable deployments
- Easy multi-environment setup (dev, staging, prod)

---

#### 2. **Updated Security Groups** 🔐
**What Changed:** Refactored security group references to use outputs from VPC module

**Before:**
```hcl
vpc_id           = var.vpc_id
vpc_cidr         = var.vpc_cidr
alb_ingress_cidr = [var.vpc_cidr]
```

**After:**
```hcl
vpc_id           = module.vpc.vpc_id
vpc_cidr         = module.vpc.vpc_cidr_block
alb_ingress_cidr = [module.vpc.vpc_cidr_block]
```

**Changes in ALB Security Group:**
- Removed hardcoded HTTP ingress rule (port 80)
- Now only allows traffic from VPC (within security group)
- More secure - no direct internet access to ALB

---

#### 3. **Lambda Functions Enhanced** 🚀
**What Changed:** Three new Lambda handlers introduced for different event types

**New Lambda Functions:**

**a) S3 to ECS Trigger (`handler.py`)**
```python
# Improvements:
- Handles multiple S3 events (not just first record)
- Ignores folder markers (zero-byte objects)
- Ignores config uploads (won't trigger processing)
- Filters for /incoming/ files only
- Extracts tenant_id from S3 key path
- Passes data via environment variables instead of command args
- Sets MODE=JOB for error processing
```

**b) Post PR Actions (`handler_post_pr_actions.py`)**
```python
# New functionality:
- Triggered by GitHub Actions webhooks
- Receives PR event payload
- Extracts tenant_id from payload
- Sets MODE=PR_EVENT
- Useful for PR-triggered actions (PR metadata to be stored in RDS and The tickets to be transitioned according to the PR events.)
```

**c) Selfheal Retry (`handler_selfheal_retry.py`)**
```python
# New functionality:
- Triggered to retry the selfheal to produce the updated fix if the previous fix fails during CI/CD.
- Sets MODE=RETRY
- Re-processes failed fix
- Essential for resilience and error recovery
```

**Environment Variables Instead of CLI Args:**
**Before:**
```python
"command": ["python", "-m", "scripts.run_all", bucket, key]
```

**After:**
```python
"environment": [
    {"name": "MODE", "value": "JOB"},
    {"name": "TENANT_ID", "value": tenant_id},
    {"name": "S3_BUCKET", "value": bucket},
    {"name": "S3_KEY", "value": key}
]
```

**Why This Matters:**
- Environment variables are more reliable
- Container can read mode and act accordingly
- Supports different modes: SERVICE, JOB, PR_EVENT, RETRY

---

#### 4. **IAM & GitHub Actions Integration** 🔑
**What Changed:** Added GitHub Actions OIDC and IAM roles for CI/CD

**New Files:**
- `modules/iam/github-oidc.tf`: Sets up OIDC provider for GitHub
- `modules/iam/github-role.tf`: IAM role for GitHub Actions
- `modules/iam/post_pr_actions.tf`: IAM user for external systems

**GitHub Actions Integration:**
```hcl
# Allows GitHub Actions to assume AWS role using OIDC
# No need for AWS access keys in GitHub secrets!
```

**Allowed Repositories (in github-role.tf):**
- `darshita-singh/error_handling_system`
- `Basavaraj011/pub-workflow-simulator`
- `Basavaraj011/error_pipeline_demo`

**Permissions:**
- ECR push: Can push images to `selfheal` ECR repository
- Lambda invoke: Can invoke `post-pr-actions-trigger` and `selfheal_retry` functions

---

#### 5. **S3 Bucket Structure Refactored** 📦
**What Changed:** Multi-tenant S3 structure implementation

**Before:**
```
incoming/
archive/
```

**After:**
```
tenants/
├── tenant_a/
│   ├── config/
│   ├── incoming/
│   └── archive/
```

**Benefits:**
- Multi-tenant isolation
- Clear organization by tenant
- Easier to secure, audit and manage tenant data
- Removed filter_prefix from S3 event notification (now handled by Lambda)

---

#### 6. **Secrets Management Improvements** 🔐
**What Changed:** Moved from hardcoded secrets module to AWS Secrets Manager patterns

**Before:**
- `module "app_secrets"` with inline environment variables in Terraform
- Exposed sensitive data in code
- Hard to rotate secrets

**After:**
- Commented out secrets module in main.tf
- Uses AWS Secrets Manager with ARN-based references
- IAM policies updated to allow access to `arn:aws:secretsmanager:${var.region}:*:secret:selfheal/*`
- Added KMS decrypt permissions for encrypted secrets

**IAM Policy Changes:**
```hcl
# Before (specific ARN):
Resource = var.secret_arn

# After (pattern-based):
Resource = "arn:aws:secretsmanager:${var.region}:*:secret:selfheal/*"
```

---

#### 7. **Lambda Variables Refactored** 📝
**What Changed:** Lambda now supports dynamic configuration

**Before:**
```hcl
function_name = "s3-to-ecs-trigger"  # Hardcoded
handler       = "handler.lambda_handler"  # Hardcoded
```

**After:**
```hcl
function_name = var.function_name
handler       = var.lambda_handler
```

**Benefits:**
- Reuse same lambda module for multiple functions
- Different handlers for different events
- Easier testing and maintenance

---

#### 8. **Terraform Provider Updates** 🔧
**What Changed:** AWS provider configuration and version constraints

**Before:**
```hcl
version = "~> 5.0"
region = var.region  # Configurable
```

**After:**
```hcl
version = ">= 5.0, < 6.0"
region = "us-east-1"  # Hardcoded
shared_credentials_files = ["~/.aws/credentials"]
profile = "default"
```

---

#### 9. **Variables.tf Cleanup** 🧹
**What Changed:** Removed unnecessary variables

**Removed Variables:**
- `vpc_id` - now created by vpc module
- `vpc_cidr` - now created by vpc module
- `availability_zones` - hardcoded in vpc module
- `create_subnets` - always true now
- `existing_private_subnet_ids` - no longer needed
- `existing_public_subnet_ids` - no longer needed
- `ecs_existing_private_subnet_ids` - no longer needed

**Simplified from 39 to ~6 variables**

---

#### 10. **Terraform.tfvars Simplified** 📋
**What Changed:** Reduced configuration requirements

**Before:**
```hcl
region = "us-east-1"
vpc_id = "vpc-0e9d7670b10ec2ef3"
vpc_cidr = "172.31.0.0/16"
create_subnets = false
availability_zones = ["us-east-1c", "us-east-1d"]
existing_private_subnet_ids = ["subnet-01b9f04bdc2a59a6e", "subnet-0200203875f2aac93"]
existing_public_subnet_ids = ["subnet-00a33dd05e8ee1d48"]
ecs_existing_private_subnet_ids = ["subnet-01b9f04bdc2a59a6e"]
image_url = "342946498337.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest"
```

**After:**
```hcl
region = "us-east-1"
image_url = "<account>.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest"
db_username = <username>
db_password = <password>
server_cert_path = "./certs/server.crt"
server_key_path = "./certs/server.key"
ca_cert_path = "./certs/ca.crt"
ca_key_path = "./certs/ca.key"
bucket_name = "self-healing-system-dgs"
```

---

### Summary of Benefits from PR #1

| Aspect | Before | After | Benefit |
|--------|--------|-------|---------|
| **VPC Setup** | Manual AWS console | Terraform automated | Repeatable, version-controlled |
| **Subnets** | Hardcoded subnet IDs | Dynamic outputs | No manual tracking |
| **Lambda** | Single purpose | Three specialized functions | Better separation of concerns |
| **Secrets** | Inline in code | AWS Secrets Manager | More secure |
| **Configuration** | 39 variables | ~6 variables | Simpler to use |
| **GitHub CI/CD** | Not supported | OIDC-based | No hardcoded credentials |
| **S3 Structure** | Flat | Multi-tenant | Scalable |
| **IAM** | Basic | Comprehensive | Better security |

---

## Module Deep Dive

### VPC Module - Detailed Configuration

```hcl
# modules/vpc/vpc.tf

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = "selfheal"
  cidr = "10.90.64.128/25"           # /25 = 128 IP addresses
  
  azs = ["us-east-1a", "us-east-1b"]  # Availability zones
  
  public_subnets  = ["10.90.64.128/27"]  # /27 = 32 IPs (public)
  private_subnets = ["10.90.64.160/27", "10.90.64.192/27"]  # /27 = 32 IPs each
  
  enable_nat_gateway = true
  single_nat_gateway = true  # Cost optimization - single NAT for all private subnets
  
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

**IP Address Breakdown:**
```
VPC CIDR: 10.90.64.128/25 (128 addresses total: 128-255)
├── Public Subnet: 10.90.64.128/27 (32 addresses: 128-159)
└── Private Subnets: 2 × /27 (64 addresses total)
    ├── Private 1: 10.90.64.160/27 (160-191)
    └── Private 2: 10.90.64.192/27 (192-223)

Reserved: 10.90.64.224/27 (224-255)
```

---

### ECS Module - Container Configuration

**Task Definition Key Settings:**
```python
# Environment mode determines behavior
MODE = "SERVICE"  # Chatbot service, always running
MODE = "JOB"      # Error processing job (S3 trigger)
MODE = "PR_EVENT" # GitHub post PR event handling
MODE = "RETRY"    # Retry failed fixes
```

**Container Port:** 3978 (Teams Bot service port)

**Resource Allocation:**
- CPU: 256 (0.25 vCPU)
- Memory: 512 MB
- Can be increased for higher traffic

---

### Lambda Handler Patterns

**Common Pattern Across All Handlers:**
```python
import boto3
import os
import json

ecs = boto3.client("ecs")

def lambda_handler(event, context):
    try:
        # 1. Parse/validate event
        # 2. Extract parameters
        # 3. Launch ECS task with environment variables
        # 4. Return success response
    except Exception as e:
        print("ERROR:", str(e))
        raise
```

**Environment Variables for ECS Task:**
```python
"environment": [
    {"name": "ECS_CLUSTER_NAME", "value": os.environ["ECS_CLUSTER_NAME"]},
    {"name": "TASK_DEFINITION_NAME", "value": os.environ["TASK_DEFINITION_NAME"]},
    {"name": "CONTAINER_NAME", "value": os.environ["CONTAINER_NAME"]},
    {"name": "ECS_SECURITY_GROUP", "value": os.environ["ECS_SECURITY_GROUP"]},
    {"name": "ECS_SUBNETS", "value": os.environ["ECS_SUBNETS"]},
    # Custom variables for the specific task
    {"name": "MODE", "value": "JOB"},
    {"name": "TENANT_ID", "value": tenant_id},
]
```

---

## Configuration & Deployment

### Prerequisites

```bash
# 1. Install Terraform
brew install terraform  # macOS
# or download from https://www.terraform.io/downloads.html

# 2. Install AWS CLI
pip install awscli

# 3. Configure AWS credentials
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Default region (us-east-1), Output format (json)

# 4. Generate VPN Certificates
# (See Client VPN section below)

# 5. Docker (for building and pushing images)
brew install docker

# 6. Git
brew install git
```

---

### Initial Deployment Steps

#### Step 1: Clone Repository
```bash
cd ~/projects
git clone https://github.com/Basavaraj011/selfheal-terraform_v1.git
cd selfheal-terraform_v1
```

#### Step 2: Generate VPN Certificates
```bash
mkdir -p certs
cd certs

# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate CA certificate
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
  -subj "/CN=SelfhealVPN-CA"

# Generate server private key
openssl genrsa -out server.key 2048

# Generate server certificate signing request
openssl req -new -key server.key -out server.csr \
  -subj "/CN=selfheal-vpn-server"

# Sign server certificate with CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out server.crt -days 365

cd ..
```

#### Step 3: Review and Update Variables
```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Key settings to verify:
# - region = "us-east-1"
# - image_url = Your ECR image URL
# - db_username, db_password = Your DB credentials
# - bucket_name = Your S3 bucket name
```

#### Step 4: Initialize Terraform
```bash
terraform init

# Output:
# - Downloads provider plugins (AWS provider)
# - Creates .terraform/ directory
# - Initializes Terraform working directory
```

#### Step 5: Plan Deployment
```bash
terraform plan -out=tfplan

# Review the plan:
# - Resources to be created
# - Dependencies
# - Any potential issues
```

#### Step 6: Apply Configuration
```bash
terraform apply tfplan

# Terraform will create all resources:
# - VPC, subnets, security groups (5-10 minutes)
# - ECS cluster and service
# - RDS database (10-15 minutes)
# - Lambda functions
# - IAM roles and policies
# - S3 bucket
# - ECR repository
# - Client VPN endpoint

# Total time: 15-30 minutes
```

---

### Building and Pushing Docker Image (Automated via GitHub action)

```bash
# Clone the application repository
git clone https://github.com/darshita-singh/error_handling_system.git
cd error_handling_system

# Build Docker image
docker build -t selfheal:latest .

# Get ECR login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag selfheal:latest <account>.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest

# Push to ECR
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest

# Verify
aws ecr describe-images --repository-name selfheal
```

---

### Updating Configuration

```bash
# Edit terraform.tfvars to change settings
nano terraform.tfvars

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

---

### Destroying Infrastructure

```bash
# WARNING: This deletes all resources!
terraform destroy

# To skip confirmation
terraform destroy -auto-approve
```

---

## Important Changes in Recent PRs

### Commit 1: "updated per multi tenant setup"
- Refactored locals to remove hardcoded subnet references
- Updated main.tf to use module outputs

### Commit 2: "removed secrets"
- Commented out app_secrets module
- Moved to AWS Secrets Manager for better security
- Updated IAM policies to use wildcards for secrets access

### Commit 3: "multi"
- Prepared multi-tenant S3 structure
- Updated Lambda handlers for tenant-based processing
- Modified S3 event filters

### Commit 4: "Network Layer Automated"
- Created VPC module for fully automated networking
- Updated all module references
- Simplified configuration and variables
- Added GitHub Actions OIDC support
- Enhanced Lambda handlers with multi-mode support

---

### Git Commands
```bash
# Clone repository
git clone https://github.com/Basavaraj011/selfheal-terraform_v1.git

# Check branch
git branch -a

# Create new branch
git checkout -b feature/your-feature-name

# Commit changes
git add .
git commit -m "Description of changes"

# Push to remote
git push origin feature/your-feature-name

# View PR #1 (Network Layer)
git log --oneline | grep -i "network\|vpc"
```

---

## Next Steps for Team Members

1. **Read this document** - Understand the architecture and components
2. **Set up local environment** - Clone repo and run `terraform init`
3. **Review key files:**
   - `main.tf` - Understand module orchestration
   - `modules/vpc/vpc.tf` - VPC configuration
   - `modules/ecs/task-definition.tf` - Container setup
   - `modules/lambda/handler.py` - Lambda logic
4. **Practice:**
   - Run `terraform plan` to see what would be deployed
   - Explore AWS Console to see deployed resources
   - Test Lambda functions locally
5. **Contribute:**
   - Create a feature branch
   - Make improvements (better documentation, new features, bug fixes)
   - Submit PR with detailed description

---

## Resources

- **Terraform Documentation:** https://www.terraform.io/docs
- **AWS Terraform Provider:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Terraform AWS Modules:** https://github.com/terraform-aws-modules
- **AWS VPC Best Practices:** https://docs.aws.amazon.com/vpc/latest/userguide/
- **ECS Documentation:** https://docs.aws.amazon.com/ecs/
- **Lambda Developer Guide:** https://docs.aws.amazon.com/lambda/
- **GitHub OIDC in AWS:** https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect

---

## Document Updates

| Date | Author | Changes |
|------|--------|---------|
| 2026-08-10 | Basavaraj011 | Initial Knowledge Transfer document created |

---

**Questions or clarifications needed? Reach out to @Basavaraj011**
