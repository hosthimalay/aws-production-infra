# AWS Production-Ready Infrastructure with Terraform

A modular, production-grade AWS infrastructure built entirely with Terraform. Provisions a secure VPC, EC2 instances with Auto Scaling, RDS database, S3 bucket with lifecycle policies, and CloudWatch monitoring — all following AWS Well-Architected Framework principles.

## Architecture Overview

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
┌──────────────────────────────────────┐
│           VPC (10.0.0.0/16)          │
│                                      │
│  ┌──────────┐    ┌──────────┐        │
│  │ Public   │    │ Public   │        │
│  │ Subnet A │    │ Subnet B │        │
│  │10.0.1.0/24   │10.0.2.0/24        │
│  └────┬─────┘    └────┬─────┘        │
│       │               │              │
│  ┌────▼───────────────▼─────┐        │
│  │    Application Load      │        │
│  │       Balancer           │        │
│  └────────────┬─────────────┘        │
│               │                      │
│  ┌────────────▼─────────────┐        │
│  │    Auto Scaling Group    │        │
│  │       (EC2 t3.micro)     │        │
│  └────────────┬─────────────┘        │
│               │                      │
│  ┌────────────▼─────────────┐        │
│  │  Private Subnet (RDS)    │        │
│  │   PostgreSQL Multi-AZ    │        │
│  └──────────────────────────┘        │
└──────────────────────────────────────┘
         │
         ▼
    S3 Bucket (logs + state)
```
Additional components:
- NAT Gateway for outbound traffic
- S3 bucket for application storage
- S3 backend for Terraform state
- DynamoDB table for state locking

### Remote State Management
- S3 backend
- DynamoDB locking
- Prevents concurrent state corruption

### High Availability
- Resources spread across 2 AZs
- Auto Scaling Group behind ALB
- RDS deployed in private subnets

### Security Design
- RDS not publicly accessible
- Layered security groups
- IAM instance profile for EC2
- Private subnet isolation

### Observability
- CloudWatch alarms
- Dashboard for ALB and EC2 metrics

## Features

- **Modular Terraform** — reusable VPC, EC2, RDS, and S3 modules
- **Remote State** — S3 backend with DynamoDB locking
- **Security** — least-privilege IAM, private subnets for RDS, security group layering
- **High Availability** — Multi-AZ RDS, Auto Scaling Group across 2 AZs
- **Observability** — CloudWatch alarms for CPU, memory, and RDS connections
- **Cost-conscious** — t3.micro instances, lifecycle policies on S3

## Tech Stack

| Tool | Version |
|------|---------|
| Terraform | >= 1.5 |
| AWS Provider | ~> 5.0 |
| AWS Region | eu-west-1 (Ireland) |

## Project Structure

```
.
├── main.tf              # Root module — wires everything together
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Your variable values (gitignored)
├── backend.tf           # S3 remote state config
├── modules/
│   ├── vpc/             # VPC, subnets, IGW, NAT, route tables
│   ├── ec2/             # Launch template, ASG, ALB, security groups
│   ├── s3/              # S3 bucket with versioning + lifecycle
│   └── rds/             # RDS PostgreSQL, subnet group, parameter group
└── cloudwatch.tf        # Alarms and dashboards
```

## Quick Start

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.5 installed
- S3 bucket for remote state (create once manually)

### Step 1 — Bootstrap remote state (one-time)
```bash
aws s3 mb s3://himalay-tf-state-bucket --region eu-west-1
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-1
```

### Step 2 — Configure variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 3 — Deploy
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 4 — Destroy (to avoid costs)
```bash
terraform destroy
```

## Estimated AWS Cost

| Resource | Monthly (approx) |
|----------|-----------------|
| EC2 t3.micro x2 | ~$15 |
| RDS db.t3.micro | ~$15 |
| ALB | ~$16 |
| NAT Gateway | ~$32 |
| **Total** | **~$78/month** |

> **Tip:** Run `terraform destroy` after showcasing. Use `terraform plan` to review before any apply.

## What This Demonstrates

- Terraform module design and reuse
- AWS networking (VPC, subnets, routing, NAT)
- Security group layering and IAM least privilege
- Remote state management with locking
- High availability across multiple AZs
- CloudWatch monitoring and alerting
- Infrastructure-as-code best practices
