output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "incoming_prefix" {
  description = "Incoming folder prefix"
  value       = "incoming/"
}

output "archive_prefix" {
  description = "Archive folder prefix"
  value       = "archive/"
}