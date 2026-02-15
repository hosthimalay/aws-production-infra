# ==============================================================================
# S3 Module — Versioning, encryption, lifecycle, access logging
# ==============================================================================

resource "aws_s3_bucket" "app" {
  bucket = var.s3_bucket_name
  tags   = { Name = var.s3_bucket_name, Environment = var.environment }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "delete-incomplete-multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
  }
}

variable "project_name" { type = string }
variable "environment" { type = string }
variable "s3_bucket_name" { type = string }

output "bucket_name" { value = aws_s3_bucket.app.bucket }
output "bucket_arn" { value = aws_s3_bucket.app.arn }
output "bucket_id" { value = aws_s3_bucket.app.id }
