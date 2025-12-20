# Production environment S3 bucket configuration

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/s3"
}

inputs = {
  bucket_name = "bs-app-prod-bucket-${get_aws_account_id()}"

  enable_versioning = "true"
  enable_encryption = "true"
  sse_algorithm     = "aws:kms"
  # kms_master_key_id = "arn:aws:kms:us-east-2:308269940941:key/12345678-1234-1234-1234-123456789012"

  block_public_acls       = "true"
  block_public_policy     = "true"
  ignore_public_acls      = "true"
  restrict_public_buckets = "true"

  enable_lifecycle        = "true"
  transition_days_ia      = "30"
  transition_days_glacier = "90"
  expiration_days         = "730"
  enable_replication      = "false"

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
