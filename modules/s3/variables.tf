variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket (string: 'true' or 'false')"
  type        = string
  default     = "false"
}

variable "enable_encryption" {
  description = "Enable server-side encryption for the S3 bucket (string: 'true' or 'false')"
  type        = string
  default     = "true"
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "KMS master key ID for encryption (required if sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "block_public_acls" {
  description = "Block public ACLs (string: 'true' or 'false')"
  type        = string
  default     = "true"
}

variable "block_public_policy" {
  description = "Block public bucket policies (string: 'true' or 'false')"
  type        = string
  default     = "true"
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs (string: 'true' or 'false')"
  type        = string
  default     = "true"
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies (string: 'true' or 'false')"
  type        = string
  default     = "true"
}

variable "enable_lifecycle" {
  description = "Enable lifecycle rules (string: 'true' or 'false')"
  type        = string
  default     = "false"
}

variable "transition_days_ia" {
  description = "Days before transitioning to Infrequent Access"
  type        = string
  default     = "30"
}

variable "transition_days_glacier" {
  description = "Days before transitioning to Glacier"
  type        = string
  default     = "90"
}

variable "expiration_days" {
  description = "Days before object expiration"
  type        = string
  default     = "365"
}

variable "enable_replication" {
  description = "Enable cross-region replication (string: 'true' or 'false')"
  type        = string
  default     = "false"
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
