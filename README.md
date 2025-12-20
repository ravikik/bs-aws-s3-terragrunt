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

### Using GitHub Actions (Recommended)

This repository includes a GitHub Actions workflow for automated deployments.

#### Prerequisites

1. **Configure AWS OIDC Provider** in your AWS account for GitHub Actions
2. **Create an IAM Role** with permissions to manage S3 and assume via OIDC
3. **Add the Role ARN** as a repository secret named `AWS_ROLE_ARN`

#### Manual Workflow Dispatch

Go to Actions → Deploy S3 Infrastructure → Run workflow

Configure the following inputs:
- **Environment**: `dev` or `prod`
- **Bucket Name**: Base name for the bucket (default: `bs-app`)
- **Enable Versioning**: `true` or `false`
- **Block Public Access**: `true` or `false`
- **Enable Lifecycle**: `true` or `false`
- **Transition Days IA**: Days before moving to Infrequent Access
- **Transition Days Glacier**: Days before moving to Glacier
- **Expiration Days**: Days before object deletion
- **Enable Replication**: `true` or `false`
- **Action**: `plan`, `apply`, or `destroy`

#### Automatic Triggers

The workflow automatically runs on:
- **Pull Requests** to main/master (runs `plan` on dev environment)
- **Pushes** to main/master (runs `plan` on dev environment)

### Local Deployment

#### Deploy to Development

```bash
cd environments/dev
terragrunt init
terragrunt plan
terragrunt apply
```

#### Deploy to Production

```bash
cd environments/prod
terragrunt init
terragrunt plan
terragrunt apply
```

#### Destroy Resources

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

## GitHub Actions Workflow

### Workflow File

[.github/workflows/deploy-s3.yml](.github/workflows/deploy-s3.yml)

### Setting Up AWS OIDC Authentication

To use GitHub Actions with AWS, you need to set up OIDC authentication:

#### 1. Create an OIDC Provider in AWS

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### 2. Create an IAM Role for GitHub Actions

Create a trust policy file (`trust-policy.json`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::308269940941:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:*"
        }
      }
    }
  ]
}
```

Create the role:

```bash
aws iam create-role \
  --role-name GitHubActionsS3Role \
  --assume-role-policy-document file://trust-policy.json
```

#### 3. Attach Permissions Policy

Create a permissions policy file (`permissions-policy.json`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*"
      ],
      "Resource": "*"
    }
  ]
}
```

Attach the policy:

```bash
aws iam put-role-policy \
  --role-name GitHubActionsS3Role \
  --policy-name S3DeploymentPolicy \
  --policy-document file://permissions-policy.json
```

#### 4. Add Secret to GitHub Repository

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `AWS_ROLE_ARN`
5. Value: `arn:aws:iam::308269940941:role/GitHubActionsS3Role`

### Workflow Features

- **Automated Planning**: Runs on pull requests and pushes to show what will change
- **Manual Deployment**: Trigger deployments manually with custom parameters
- **Environment Selection**: Deploy to dev or prod environments
- **Dynamic Configuration**: Override bucket settings via workflow inputs
- **Plan Comments**: Automatically comments Terraform plans on pull requests
- **Deployment Summary**: Shows bucket outputs after successful deployment
