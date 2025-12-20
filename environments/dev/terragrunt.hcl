# Development environment S3 bucket configuration

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/s3"
}

inputs = {
  bucket_name = "bs-app-dev-bucket-${get_aws_account_id()}"

  enable_versioning = "true"
  enable_encryption = "true"
  sse_algorithm     = "AES256"

  block_public_acls       = "true"
  block_public_policy     = "true"
  ignore_public_acls      = "true"
  restrict_public_buckets = "true"

  enable_lifecycle    = "true"
  transition_days_ia  = "30"
  transition_days_glacier = "90"
  expiration_days     = "365"
  enable_replication  = "false"

  lifecycle_rules = [
    {
      id     = "cleanup-old-versions"
      status = "Enabled"
      expiration = {
        days = 90
      }
    }
  ]

  tags = {
    Project = "MyApp"
    Owner   = "DevTeam"
  }
}
