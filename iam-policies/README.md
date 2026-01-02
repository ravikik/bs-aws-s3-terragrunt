# IAM Policies for GitHub Actions

This directory contains IAM policies required for GitHub Actions to deploy S3 infrastructure using Terragrunt.

## Files

### 1. github-actions-trust-policy.json

Trust policy that allows GitHub Actions to assume the IAM role using OIDC authentication.

**Important:** Update the following in this file:
- Replace `YOUR_GITHUB_ORG/YOUR_REPO_NAME` with your actual GitHub organization and repository name
- Example: `repo:myorg/myrepo:*`

### 2. github-actions-permissions.json

Permissions policy that grants the necessary AWS permissions for managing S3 buckets and DynamoDB state locking.

**Permissions included:**

#### S3 Bucket Management
- Create, delete, and manage S3 buckets
- Configure versioning, encryption, lifecycle rules
- Manage public access blocking
- Scoped to buckets matching `bs-app-*` pattern and the state bucket

#### DynamoDB State Locking
- Access to `terraform-locks` table for state locking
- DescribeTable, GetItem, PutItem, DeleteItem operations

#### KMS Encryption
- Encrypt/decrypt operations for S3 and DynamoDB
- Scoped to us-east-2 region via service condition

## Usage

### Create the IAM Role

```bash
# 1. Update the trust policy with your GitHub org/repo
# Edit: iam-policies/github-actions-trust-policy.json

# 2. Create the role
aws iam create-role \
  --role-name github-actions-terragrunt \
  --assume-role-policy-document file://iam-policies/github-actions-trust-policy.json

# 3. Attach the permissions policy
aws iam put-role-policy \
  --role-name github-actions-terragrunt \
  --policy-name S3DeploymentPolicy \
  --policy-document file://iam-policies/github-actions-permissions.json
```

### Update Existing Role

If you need to update the permissions:

```bash
aws iam put-role-policy \
  --role-name github-actions-terragrunt \
  --policy-name S3DeploymentPolicy \
  --policy-document file://iam-policies/github-actions-permissions.json
```

### Verify Permissions

```bash
# Get the current policy
aws iam get-role-policy \
  --role-name github-actions-terragrunt \
  --policy-name S3DeploymentPolicy

# List all policies attached to the role
aws iam list-role-policies --role-name github-actions-terragrunt
```

## Security Best Practices

1. **Least Privilege**: The permissions are scoped to specific resources and actions needed
2. **Resource Scoping**: S3 permissions limited to `bs-app-*` buckets and state bucket
3. **Service Conditions**: KMS permissions limited to specific AWS services
4. **Regional Restrictions**: KMS access scoped to us-east-2 region
5. **No Wildcards**: Avoided using `*` for resources where possible

## Troubleshooting

### Access Denied Errors

If you encounter access denied errors:

1. Check the CloudTrail logs for the specific action being denied
2. Add the required permission to `github-actions-permissions.json`
3. Update the role policy using the command above
4. Retry the GitHub Actions workflow

### Common Issues

- **DynamoDB Access Denied**: Ensure `terraform-locks` table exists in the correct region
- **S3 Access Denied**: Verify bucket name matches the pattern `bs-app-*`
- **KMS Access Denied**: Check that KMS key policy allows the role to use it
