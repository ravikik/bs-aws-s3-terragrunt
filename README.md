# S3 Terragrunt Modules

This repository contains Terragrunt modules for provisioning AWS S3 buckets across multiple environments.

## Structure

```
.
├── modules/
│   └── s3/                    # Reusable S3 Terraform module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/                   # Development environment
│   │   ├── env.hcl
│   │   └── terragrunt.hcl
│   └── prod/                  # Production environment
│       ├── env.hcl
│       └── terragrunt.hcl
├── terragrunt.hcl             # Root Terragrunt configuration
├── account.hcl                # AWS account configuration
└── region.hcl                 # AWS region configuration
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.45
- AWS CLI configured with appropriate credentials

## Configuration

Before using this module, update the following files:

1. **account.hcl** - Set your AWS account ID
2. **region.hcl** - Set your preferred AWS region
3. **terragrunt.hcl** - Update the S3 backend bucket name (ensure it exists or create it first)
4. **environments/*/terragrunt.hcl** - Customize bucket names and settings for each environment

## Usage

### Deploy to Development

```bash
cd environments/dev
terragrunt init
terragrunt plan
terragrunt apply
```

### Deploy to Production

```bash
cd environments/prod
terragrunt init
terragrunt plan
terragrunt apply
```

### Destroy Resources

```bash
cd environments/dev
terragrunt destroy
```

## Module Features

The S3 module supports:

- Bucket creation with custom naming
- Versioning (optional)
- Server-side encryption (AES256 or KMS)
- Public access blocking
- Lifecycle rules for transitions and expiration
- Custom tagging

## State Management

Terraform state is stored in S3 with DynamoDB locking. Ensure the backend S3 bucket and DynamoDB table exist before running Terragrunt:

```bash
# Create the state bucket
aws s3 mb s3://terraform-state-<account-id>

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-<account-id> \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Outputs

The module outputs:

- `bucket_id` - The S3 bucket ID
- `bucket_arn` - The S3 bucket ARN
- `bucket_domain_name` - The bucket domain name
- `bucket_regional_domain_name` - The bucket regional domain name
