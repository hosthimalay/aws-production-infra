# ==============================================================================
# Remote State Backend — S3 + DynamoDB locking
# Create the S3 bucket and DynamoDB table manually before running terraform init
# See README.md Step 1 for bootstrap commands
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "himalay-tf-state-2026"   # Change to your bucket name
    key            = "aws-infra/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"       # DynamoDB table for locking
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-production-infra"
      ManagedBy   = "Terraform"
      Owner       = "himalay-dhaije"
      Environment = var.environment
    }
  }
}
