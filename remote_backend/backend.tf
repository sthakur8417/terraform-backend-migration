# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "s3statebackend84170703"

  # Add tags for better resource management
  tags = {
    Environment = "Production"
    Purpose     = "Terraform State"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable logging for S3 bucket
resource "aws_s3_bucket_logging" "my_bucket_logging" {
  bucket = aws_s3_bucket.my_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "tfstate-logs/"
}

# Create a separate bucket for logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "s3statebackend84170703-logs"

  tags = {
    Environment = "Production"
    Purpose     = "Terraform State Logs"
    ManagedBy   = "Terraform"
  }
}

# Enable lifecycle rules for log bucket
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "log_retention"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

# DynamoDB table with enhanced settings
resource "aws_dynamodb_table" "statelock" {
  name         = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Environment = "Production"
    Purpose     = "Terraform State Lock"
    ManagedBy   = "Terraform"
  }
}


# S3 bucket policy
resource "aws_s3_bucket_policy" "state_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceTLSRequestsOnly"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
