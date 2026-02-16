variable "buckets" {
  type = list(object({
    name                               = string
    tier                               = string
    encryption                         = string
    kms_key_arn                        = string
    bucket_key_enabled                 = bool
    versioning                         = bool
    mfa_delete                         = bool
    lifecycle_rules                    = list(string)
    intelligent_tiering                = bool
    abort_incomplete_multipart_days    = number
    noncurrent_version_expiration_days = number
    block_public_access                = bool
    enforce_ssl                        = bool
    access_logging                     = bool
    log_target_bucket                  = string
    log_prefix                         = string
    replication_enabled                = bool
    replication_destination_bucket     = string
    replication_destination_region     = string
    transfer_acceleration              = bool
    object_lock_enabled                = bool
    object_lock_mode                   = string
    object_lock_retention_days         = number
    tags                               = map(string)
  }))
}

variable "medallion_structure" {
  type    = bool
  default = true
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "project_name" {
  type    = string
  default = "prismflow"
}
