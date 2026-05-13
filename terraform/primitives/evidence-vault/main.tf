terraform {
  required_version = ">= 1.6"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = "us-east-1"
  # CM-6: Configuration settings. Required compliance tags applied to every
  # taggable resource by default. Same pattern as labs 2.3 and 2.4.
  default_tags {
    tags = {
      Project         = var.project_name
      Environment     = "evidence"
      ManagedBy       = "terraform"
      ComplianceScope = "cge-p-lab"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  vault_name = "${var.project_name}-grc-evidence-vault-${random_id.suffix.hex}"
}

# AU-9 / AU-11: Audit information protection and retention.
# The vault bucket. object_lock_enabled MUST be set at bucket creation; AWS
# does not allow retrofitting Object Lock onto an existing bucket.
resource "aws_s3_bucket" "vault" {
  bucket              = local.vault_name
  object_lock_enabled = true
}

# Object Lock requires versioning. AWS enforces this at the API level: you
# cannot have one without the other. Versioning gives every object a unique
# VersionId, which is the durable handle the capture script will record.
resource "aws_s3_bucket_versioning" "vault" {
  bucket = aws_s3_bucket.vault.id
  versioning_configuration {
    status = "Enabled"
  }
}

# AU-11: Audit record retention. The default retention rule the bucket applies
# to every uploaded object automatically. Set it once on the bucket; do not
# set it per-object in the capture script.
resource "aws_s3_bucket_object_lock_configuration" "vault" {
  bucket = aws_s3_bucket.vault.id

  rule {
    default_retention {
      mode = var.lock_mode # GOVERNANCE for labs, COMPLIANCE for real
      days = var.retention_days
    }
  }

  # Belt-and-suspenders: versioning must exist before the lock config is
  # accepted. Terraform usually figures this out, but the explicit dependency
  # prevents race conditions on first apply.
  depends_on = [aws_s3_bucket_versioning.vault]
}

# SC-28: Protection of information at rest. AES256 (SSE-S3) is the lab's
# choice; production evidence would use SSE-KMS with a customer-managed key.
resource "aws_s3_bucket_server_side_encryption_configuration" "vault" {
  bucket = aws_s3_bucket.vault.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# AC-3: Access enforcement. Block all forms of public access at the bucket
# level. Same four-flag pattern as Lab 2.3 — same control, same family.
resource "aws_s3_bucket_public_access_block" "vault" {
  bucket                  = aws_s3_bucket.vault.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Data source: look up the current AWS account ID at plan time. Used to build
# the root ARN in the bucket policy below without hardcoding the account.
data "aws_caller_identity" "current" {}

# AU-9: Protection of audit information. Deny DeleteBucket for everyone
# except the account root. The vault should be effectively undeletable by
# day-to-day operators, even those with broad S3 permissions.
resource "aws_s3_bucket_policy" "vault" {
  bucket = aws_s3_bucket.vault.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyBucketDeletion"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:DeleteBucket"
      Resource  = aws_s3_bucket.vault.arn
      Condition = {
        StringNotEquals = {
          "aws:PrincipalArn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    }]
  })
}
