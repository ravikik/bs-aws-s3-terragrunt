# Production environment S3 bucket configuration

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/s3"
}

inputs = {
  bucket_name = "my-app-prod-bucket-${get_aws_account_id()}"

  enable_versioning = true
  enable_encryption = true
  sse_algorithm     = "aws:kms"
  # kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_rules = [
    {
      id     = "transition-to-ia"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = {
    Project = "MyApp"
    Owner   = "OpsTeam"
  }
}
