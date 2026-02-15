output "bucket_ids" {
  value = { for k, v in aws_s3_bucket.buckets : k => v.id }
}

output "bucket_arns" {
  value = { for k, v in aws_s3_bucket.buckets : k => v.arn }
}

output "buckets_with_replication" {
  value = [for k, v in aws_s3_bucket_replication_configuration.buckets : k]
}

output "buckets_with_logging" {
  value = [for k, v in aws_s3_bucket_logging.buckets : k]
}
