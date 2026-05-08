variable "task_role_name" {
  type        = string
  description = "ECS task role name"
}

variable "execution_role_name" {
  type        = string
  description = "ECS execution role name"
}

variable "secret_arn" {
  type        = string
  description = "Secrets Manager secret ARN"
}

variable "bucket_name" {
  description = "Name of the S3 bucket ECS tasks need to access"
  type        = string
}
