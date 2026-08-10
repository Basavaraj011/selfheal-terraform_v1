# AWS Architecture Diagram - Selfheal Infrastructure

## 🏗️ High-Level System Architecture with AWS Icons

```
                                        ┌─────────────────────────────────────┐
                                        │    EXTERNAL SYSTEMS & USERS         │
                                        │─────────────────────────────────────│
                                        │  🌐 GitHub Actions    💼 MS Teams   │
                                        │  🔗 Webhooks          👥 Users      │
                                        │  📦 Jira, Bitbucket   🤖 Bots       │
                                        └────────────┬──────────────────────┘
                                                     │
                                    ┌────────────────┼────────────────┐
                                    │                │                │
                              ┌─────▼──────┐  ┌────▼─────┐  ┌───────▼─────┐
                              │ 📌 OIDC     │  │🌐 API    │  │ 📨 Webhooks│
                              │ GitHub      │  │ Gateway  │  │ Incoming    │
                              │ Actions     │  │          │  │             │
                              └─────┬──────┘  └────┬─────┘  └───────┬─────┘
                                    │             │                 │
                        ┌───────────┴─────────────┴─────────────────┴──────────┐
                        │                                                       │
                        │        AWS REGION: us-east-1 (N. Virginia)          │
                        │  ┌──────────────────────────────────────────────┐   │
                        │  │                                              │   │
                        │  │  ┌─ Internet Gateway (IGW) ──────────────┐  │   │
                        │  │  │                                        │  │   │
                        │  │  │  ┌─── VPC: 10.90.64.128/25 ──────┐   │  │   │
                        │  │  │  │                                 │   │  │   │
                        │  │  │  │  ┌──────────────────────────┐  │   │  │   │
                        │  │  │  │  │  PUBLIC SUBNET           │  │   │  │   │
                        │  │  │  │  │  us-east-1a              │  │   │  │   │
                        │  │  │  │  │  10.90.64.128/27         │  │   │  │   │
                        │  │  │  │  │  ┌────────────────────┐  │  │   │  │   │
                        │  │  │  │  │  │  🌍 NAT Gateway    │  │  │   │  │   │
                        │  │  │  │  │  │  (Outbound Access) │  │  │   │  │   │
                        │  │  │  │  │  └────────────────────┘  │  │   │  │   │
                        │  │  │  │  └──────────────────────────┘  │   │  │   │
                        │  │  │  │                                 │   │  │   │
                        │  │  │  │  ┌──────────────────────────┐  │   │  │   │
                        │  │  │  │  │  PRIVATE SUBNET 1        │  │   │  │   │
                        │  │  │  │  │  us-east-1a              │  │   │  │   │
                        │  │  │  │  │  10.90.64.160/27         │  │   │  │   │
                        │  │  │  │  │                          │  │   │  │   │
                        │  │  │  │  │  ┌──────────────────┐   │  │   │  │   │
                        │  │  │  │  │  │ 📦 ALB (Port 3978)   │  │   │  │   │
                        │  │  │  │  │  │ Load Balancer    │  │   │  │   │
                        │  │  │  │  │  └─────────┬────────┘   │  │   │  │   │
                        │  │  │  │  │            │             │  │   │  │   │
                        │  │  │  │  │  ┌─────────▼────────┐   │  │   │  │   │
                        │  │  │  │  │  │ ⚙️ Lambda 1      │   │  │   │  │   │
                        │  │  │  │  │  │ s3-to-ecs        │   │  │   │  │   │
                        │  │  │  │  │  │ -trigger         │   │  │   │  │   │
                        │  │  │  │  │  │ (handler.py)     │   │  │   │  │   │
                        │  │  │  │  │  └──────────────────┘   │  │   │  │   │
                        │  │  │  │  └──────────────────────────┘  │   │  │   │
                        │  │  │  │                                 │   │  │   │
                        │  │  │  │  ┌──────────────────────────┐  │   │  │   │
                        │  │  │  │  │  PRIVATE SUBNET 2        │  │   │  │   │
                        │  │  │  │  │  us-east-1b              │  │   │  │   │
                        │  │  │  │  │  10.90.64.192/27         │  │   │  │   │
                        │  │  │  │  │                          │  │   │  │   │
                        │  │  │  │  │  ┌──────────────────┐   │  │   │  │   │
                        │  │  │  │  │  │ 🐳 ECS Fargate   │   │  │   │  │   │
                        │  │  │  │  │  │ Cluster:         │   │  │   │  │   │
                        │  │  │  │  │  │ selfheal-cluster │   │  │   │  │   │
                        │  │  │  │  │  │                  │   │  │   │  │   │
                        │  │  │  │  │  │ ▶️ Service Task   │   │  │   │  │   │
                        │  │  │  │  │  │ MODE=SERVICE     │   │  │   │  │   │
                        │  │  │  │  │  │ CPU: 256         │   │  │   │  │   │
                        │  │  │  │  │  │ Mem: 512MB       │   │  │   │  │   │
                        │  │  │  │  │  └──────────────────┘   │  │   │  │   │
                        │  │  │  │  │                          │  │   │  │   │
                        │  │  │  │  │  ┌──────────────────┐   │  │   │  │   │
                        │  │  │  │  │  │ ⚙️ Lambda 2      │   │  │   │  │   │
                        │  │  │  │  │  │ post-pr-actions  │   │  │   │  │   │
                        │  │  │  │  │  │ -trigger         │   │  │   │  │   │
                        │  │  │  │  │  │ (GitHub Webhook) │   │  │   │  │   │
                        │  │  │  │  │  └──────────────────┘   │  │   │  │   │
                        │  │  │  │  │                          │  │   │  │   │
                        │  │  │  │  │  ┌──────────────────┐   │  │   │  │   │
                        │  │  │  │  │  │ ⚙️ Lambda 3      │   │  │   │  │   │
                        │  │  │  │  │  │ selfheal-retry   │   │  │   │  │   │
                        │  │  │  │  │  │ (Retry Logic)    │   │  │   │  │   │
                        │  │  │  │  │  └──────────────────┘   │  │   │  │   │
                        │  │  │  │  │                          │  │   │  │   │
                        │  │  │  │  │  ┌──────────────────┐   │  │   │  │   │
                        │  │  │  │  │  │ 🗄️ RDS Database  │   │  │   │  │   │
                        │  │  │  │  │  │ SQL Server       │   │  │   │  │   │
                        │  │  │  │  │  │ Multi-AZ         │   │  │   │  │   │
                        │  │  │  │  │  │ Port: 1433       │   │  │   │  │   │
                        │  │  │  │  │  │ Multi-AZ Replica │   │  │   │  │   │
                        │  │  │  │  │  │ (us-east-1b)     │   │  │   │  │   │
                        │  │  │  │  │  └──────────────────┘   │  │   │  │   │
                        │  │  │  │  └──────────────────────────┘  │   │  │   │
                        │  │  │  │                                 │   │  │   │
                        │  │  │  │  ┌──────────────────────────┐  │   │  │   │
                        │  │  │  │  │  VPN ENDPOINT            │  │   │  │   │
                        │  │  │  │  │  (Secure Remote Access)  │  │   │  │   │
                        │  │  │  │  │                          │  │   │  │   │
                        │  │  │  │  │  🔐 Client VPN           │  │   │  │   │
                        │  │  │  │  │  Port: 443 (UDP)         │  │   │  │   │
                        │  │  │  │  │  Auth: Certificates      │  │   │  │   │
                        │  │  │  │  │  Split Tunneling: ON     │  │   │  │   │
                        │  │  │  │  └──────────────────────────┘  │   │  │   │
                        │  │  │  │                                 │   │  │   │
                        │  │  │  └─────────────────────────────────┘   │  │   │
                        │  │  │                                        │  │   │
                        │  │  └────────────────────────────────────────┘  │   │
                        │  │                                              │   │
                        │  │  ┌───── AWS MANAGED SERVICES ─────────────┐ │   │
                        │  │  │                                         │ │   │
                        │  │  │  ┌─────────────────────────────────┐   │ │   │
                        │  │  │  │ 📦 S3 Bucket                   │   │ │   │
                        │  │  │  │ self-healing-system-dgs         │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Multi-tenant Structure:         │   │ │   │
                        │  │  │  │ tenants/                        │   │ │   │
                        │  │  │  │  └── tenant_a/                 │   │ │   │
                        │  │  │  │      ├── config/               │   │ │   │
                        │  │  │  │      ├── incoming/   ◄─ Trigger│   │ │   │
                        │  │  │  │      └── archive/              │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Event Notification:            │   │ │   │
                        │  │  │  │ ObjectCreated → Lambda 1       │   │ │   │
                        │  │  │  └─────────────────────────────────┘   │ │   │
                        │  │  │                                         │ │   │
                        │  │  │  ┌─────────────────────────────────┐   │ │   │
                        │  │  │  │ 🐳 ECR Repository               │   │ │   │
                        │  │  │  │ selfheal                        │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Docker Images:                  │   │ │   │
                        │  │  │  │ selfheal:latest                 │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Pushed by:                      │   │ │   │
                        │  │  │  │ GitHub Actions (OIDC)           │   │ │   │
                        │  │  │  └─────────────────────────────────┘   │ │   │
                        │  │  │                                         │ │   │
                        │  │  │  ┌─────────────────────────────────┐   │ │   │
                        │  │  │  │ 🔐 Secrets Manager              │   │ │   │
                        │  │  │  │ arn:aws:secretsmanager:...      │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Secrets:                        │   │ │   │
                        │  │  │  │ • DATABASE_URL                  │   │ │   │
                        │  │  │  │ • API_KEYS                      │   │ │   │
                        │  │  │  │ • JIRA_TOKEN                    │   │ │   │
                        │  │  │  │ • BEDROCK_CREDENTIALS           │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Encryption: KMS                 │   │ │   │
                        │  │  │  └─────────────────────────────────┘   │ │   │
                        │  │  │                                         │ │   │
                        │  │  │  ┌─────────────────────────────────┐   │ │   │
                        │  │  │  │ 📊 CloudWatch Logs              │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Log Groups:                     │   │ │   │
                        │  │  │  │ • /ecs/selfheal                 │   │ │   │
                        │  │  │  │ • /aws/lambda/*                 │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Monitoring:                     │   │ │   │
                        │  │  │  │ Dashboards, Alarms, Insights    │   │ │   │
                        │  │  │  └─────────────────────────────────┘   │ │   │
                        │  │  │                                         │ │   │
                        │  │  │  ┌─────────────────────────────────┐   │ │   │
                        │  │  │  │ 🔐 IAM Roles & Policies         │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Roles:                          │   │ │   │
                        │  │  │  │ • ECS Execution Role            │   │ │   │
                        │  │  │  │ • ECS Task Role                 │   │ │   │
                        │  │  │  │ • Lambda Roles (3x)             │   │ │   │
                        │  │  │  │ • GitHub Actions Role (OIDC)    │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ Permissions:                    │   │ │   │
                        │  │  │  │ • S3 read/write                 │   │ │   │
                        │  │  │  │ • ECS task invoke               │   │ │   │
                        │  │  │  │ • Secrets access                │   │ │   │
                        │  │  │  │ • ECR push/pull                 │   │ │   │
                        │  │  │  │ • CloudWatch logs               │   │ │   │
                        │  │  │  └─────────────────────────────────┘   │ │   │
                        │  │  │                                         │ │   │
                        │  │  │  ┌─────────────────────────────────┐   │ │   │
                        │  │  │  │ 🛡️ Security Groups              │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ ALB-SG:                         │   │ │   │
                        │  │  │  │ ├─ Ingress: VPC CIDR (3978)    │   │ │   │
                        │  │  │  │ └─ Egress: All                 │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ ECS-SG:                         │   │ │   │
                        │  │  │  │ ├─ Ingress: ALB-SG             │   │ │   │
                        │  │  │  │ └─ Egress: All                 │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ RDS-SG:                         │   │ │   │
                        │  │  │  │ ├─ Ingress: ECS-SG (1433)      │   │ │   │
                        │  │  │  │ └─ Egress: None                │   │ │   │
                        │  │  │  │                                 │   │ │   │
                        │  │  │  │ VPN-SG:                         │   │ │   │
                        │  │  │  │ ├─ Ingress: VPC (443/UDP)      │   │ │   │
                        │  │  │  │ └─ Egress: All                 │   │ │   │
                        │  │  │  └─────────────────────────────────┘   │ │   │
                        │  │  │                                         │ │   │
                        │  │  └─────────────────────────────────────────┘ │   │
                        │  │                                              │   │
                        │  └──────────────────────────────────────────────┘   │
                        │                                                     │
                        └─────────────────────────────────────────────────────┘
```

---

## 📊 Detailed Data Flow Diagrams

### Flow 1: S3 Error Log Processing

```
┌──────────────┐
│  Developer   │
│ Uploads File │
└──────┬───────┘
       │
       ▼
┌───────────────────────────────────────┐
│  S3 Bucket: incoming/error_*.log      │
│  (self-healing-system-dgs)            │
└────────────┬────────────────────────┘
             │
    (ObjectCreated Event)
             │
             ▼
┌───────────────────────────────────────┐
│  Lambda 1: s3-to-ecs-trigger         │
│  ✓ Validates file                     │
│  ✓ Extracts tenant_id                 │
│  ✓ Checks file size & location        │
└────────────┬────────────────────────┘
             │
             ▼
┌───────────────────────────────────────┐
│  ECS Task Launched                    │
│  MODE=JOB                             │
│  ENV:                                 │
│  • TENANT_ID = tenant_a               │
│  • S3_BUCKET = bucket_name            │
│  • S3_KEY = tenants/tenant_a/...      │
└────────────┬────────────────────────┘
             │
             ├─────────────┬──────────────┐
             │             │              │
             ▼             ▼              ▼
        ┌────────┐   ┌─────────┐   ┌──────────┐
        │ Read   │   │Analyze  │   │ Query    │
        │from S3 │──▶│Error    │──▶│ RDS for  │
        │        │   │Log      │   │ Context  │
        └────────┘   └─────────┘   └──────────┘
             │
             ▼
        ┌────────────────┐
        │  Process Error │
        │  • Parse       │
        │  • Categorize  │
        │  • Suggest Fix │
        └────────┬───────┘
                 │
         ┌───────┴────────┐
         │                │
         ▼                ▼
    ┌─────────┐      ┌──────────┐
    │ Store   │      │ Archive  │
    │ Results │      │ to       │
    │ in RDS  │      │ S3       │
    └─────────┘      └──────────┘
```

---

### Flow 2: GitHub PR Event Processing

```
┌──────────────────────┐
│  GitHub Actions      │
│  Workflow            │
│  (PR triggered)      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  Webhook to Lambda 2                 │
│  post-pr-actions-trigger             │
│  Event Payload:                      │
│  {                                   │
│    "action": "opened",               │
│    "number": 42,                     │
│    "pull_request": {...}             │
│  }                                   │
└──────────┬───────────────────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  Lambda 2 Processing                 │
│  ✓ Validates payload                 │
│  ✓ Extracts tenant_id & PR details   │
│  ✓ Authorizes request                │
└──────────┬───────────────────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  ECS Task Launched                   │
│  MODE=PR_EVENT                       │
│  ENV:                                │
│  • TENANT_ID = tenant_a              │
│  • PR_NUMBER = 42                    │
│  • PR_PAYLOAD = {...}                │
│  • REPO = owner/repo                 │
└──────────┬───────────────────────────┘
           │
    ┌──────┴──────┬──────────┐
    │             │          │
    ▼             ▼          ▼
┌────────┐  ┌─────────┐  ┌──────────┐
│ Review │  │ Run     │  │ Update   │
│ Code   │─▶│ Tests   │─▶│ PR       │
│        │  │         │  │ Status   │
└────────┘  └─────────┘  └────┬─────┘
                               │
                    ┌──────────┴───────────┐
                    │                      │
                    ▼                      ▼
                ┌────────────┐        ┌──────────┐
                │ Approved   │        │ Declined │
                │ Merge OK   │        │ w/Issues │
                └────────────┘        └──────────┘
```

---

### Flow 3: Container Communication

```
┌─────────────────────────────────┐
│     Teams Bot / User Request     │
└────────────────┬────────────────┘
                 │
                 ▼
         ┌──────────────────┐
         │  API Gateway     │
         │  VPC Link        │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  ALB (Port 3978) │
         │  Target Group    │
         └────────┬─────────┘
                  │
                  ▼
    ┌─────────────────────────────┐
    │   ECS Task Container        │
    │   MODE=SERVICE              │
    │                             │
    │  ┌─────────────────────┐   │
    │  │ Application Logic   │   │
    │  │ (Flask/Python)      │   │
    │  └──────────┬──────────┘   │
    │             │              │
    │    ┌────────┴───────┐      │
    │    │                │      │
    │    ▼                ▼      │
    │ ┌──────────┐  ┌──────────┐ │
    │ │ RDS      │  │Secrets   │ │
    │ │Database  │  │Manager   │ │
    │ │Query     │  │Fetch     │ │
    │ └──────────┘  │Keys      │ │
    │               └──────────┘ │
    │                            │
    └────────────┬───────────────┘
                 │
                 ▼
         ┌──────────────────┐
         │  ALB Response    │
         │  Status: 200 OK  │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  API Gateway     │
         │  Response        │
         └────────┬─────────┘
                  │
                  ▼
      ┌──────────────────────┐
      │  Teams Bot          │
      │  Sends Reply        │
      │  to User            │
      └──────────────────────┘
```

---

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────┐
│         INTERNET (Public Access)                    │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Internet Gateway     │
        │ (IGW)                │
        │ Route: 0.0.0.0/0     │
        └──────────┬───────────┘
                   │
     ┌─────────────┴──────────────┐
     │                            │
     ▼                            ▼
┌──────────────────┐      ┌──────────────────────┐
│ Public Subnet    │      │ API Gateway / ALB    │
│ (NAT Gateway)    │      │ (Public Endpoint)    │
└──────────────────┘      └──────────┬───────────┘
     │                               │
     │ Outbound Only                 │ VPC Link
     │                               │
     ├───────────────────┬───────────┘
     │                   │
     ▼                   ▼
┌────────────────────────────────────────────┐
│    PRIVATE SUBNETS (Protected)             │
│    - No direct internet access             │
│    - Outbound via NAT Gateway              │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ ECS Tasks                            │ │
│  │ ✓ Security Group controlled          │ │
│  │ ✓ IAM Role attached                  │ │
│  │ ✓ VPC endpoints for AWS services     │ │
│  └──────────────────────────────────────┘ │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ RDS Database                         │ │
│  │ ✓ Encryption at rest (KMS)          │ │
│  │ ✓ SSL/TLS for connections           │ │
│  │ ✓ Restricted security group          │ │
│  │ ✓ Multi-AZ for HA                    │ │
│  └──────────────────────────────────────┘ │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ Lambda Functions                     │ │
│  │ ✓ IAM roles (least privilege)        │ │
│  │ ✓ Environment variable secrets       │ │
│  │ ✓ VPC networking                     │ │
│  └──────────────────────────────────────┘ │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ VPN Endpoint                         │ │
│  │ ✓ Certificate-based auth             │ │
│  │ ✓ Split tunneling                    │ │
│  │ ✓ Logs disabled for privacy          │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
     │
     ▼
┌────────────────────────────────────────────┐
│    AWS Managed Services (Secured)          │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ S3 (Bucket Policy)                   │ │
│  │ ✓ Block public access                │ │
│  │ ✓ Encryption by default              │ │
│  │ ✓ Versioning enabled                 │ │
│  └──────────────────────────────────────┘ │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ Secrets Manager                      │ │
│  │ ✓ KMS encryption                     │ │
│  │ ✓ Rotation policies                  │ │
│  │ ✓ Audit logging                      │ │
│  └──────────────────────────────────────┘ │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │ ECR (Repository Policy)              │ │
│  │ ✓ Image scanning                     │ │
│  │ ✓ Encryption (KMS)                   │ │
│  │ ✓ Private access only                │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Summary

| Flow | Trigger | Lambda | Mode | Purpose |
|------|---------|--------|------|---------|
| **S3 → ECS** | File uploaded to S3 `/incoming/` | Lambda 1 | JOB | Process error logs |
| **GitHub → ECS** | PR event / Webhook | Lambda 2 | PR_EVENT | Handle PR actions |
| **Manual → ECS** | API call / Manual trigger | Lambda 3 | RETRY | Retry failed ops |
| **Service** | Always running | N/A | SERVICE | Teams Bot service |

---

## 📈 Scaling Architecture

```
┌─────────────────────────────────────────┐
│   CURRENT (Single Instance)             │
│                                          │
│   ┌────────────────┐                   │
│   │ 1 × ECS Task   │ ◄── Scalable      │
│   │ 1 × RDS        │                   │
│   │ 1 × NAT GW     │                   │
│   └────────────────┘                   │
└─────────────────────────────────────────┘
                 │
                 ▼ (Scale Up)
┌─────────────────────────────────────────┐
│   SCALED (Multi-Instance)               │
│                                          │
│   ┌────────────────────────────┐       │
│   │ N × ECS Tasks (Fargate)    │ ◄──   │
│   │ Auto-scaling enabled       │       │
│   │ Load balanced via ALB      │       │
│   └────────────────────────────┘       │
│                                          │
│   ┌────────────────────────────┐       │
│   │ RDS Multi-AZ               │ ◄──   │
│   │ Read Replicas (optional)   │       │
│   └────────────────────────────┘       │
│                                          │
│   ┌────────────────────────────┐       │
│   │ Multiple NAT Gateways      │ ◄──   │
│   │ Per subnet (HA)            │       │
│   └────────────────────────────┘       │
│                                          │
│   ┌────────────────────────────┐       │
│   │ Lambda (Auto-scales)       │ ◄──   │
│   │ Concurrent invocations     │       │
│   └────────────────────────────┘       │
└─────────────────────────────────────────┘
```

---

## 🎯 Key Architecture Highlights

### ✅ **Security**
- ✓ VPC with public/private subnets
- ✓ Security groups (firewall)
- ✓ IAM roles (least privilege)
- ✓ Secrets Manager (encrypted)
- ✓ VPN for admin access
- ✓ KMS encryption

### ✅ **High Availability**
- ✓ Multi-AZ RDS
- ✓ ALB with health checks
- ✓ Auto-scaling capable
- ✓ Fargate (managed service)

### ✅ **Scalability**
- ✓ Serverless Lambda
- ✓ S3 unlimited storage
- ✓ ECS Fargate auto-scale
- ✓ RDS read replicas (optional)

### ✅ **Monitoring**
- ✓ CloudWatch logs
- ✓ CloudWatch dashboards
- ✓ CloudWatch alarms
- ✓ X-Ray tracing

### ✅ **Cost Optimization**
- ✓ Single NAT Gateway
- ✓ Fargate Spot (non-critical)
- ✓ RDS on-demand pricing
- ✓ Lambda pay-per-invoke

---

## 📞 Legend

| Symbol | Meaning |
|--------|---------|
| 🌍 | Internet Gateway |
| 📦 | ALB / ECS |
| 🐳 | Docker Container |
| ⚙️ | Lambda Function |
| 🗄️ | Database |
| 🔐 | Security / VPN |
| 📊 | Monitoring |
| 🌐 | Network |

---

**For detailed module configurations, see:** [KNOWLEDGE_TRANSFER.md](./KNOWLEDGE_TRANSFER.md)
