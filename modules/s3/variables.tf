variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "lambda_arn" {
  type        = string
  description = "ARN of the Lambda function to trigger"
}