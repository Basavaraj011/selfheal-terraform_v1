variable "resource_suffix" {
  type        = string
  description = "Suffix for IAM role names"
}

variable "execution_role_name" {
  type        = string
  description = "ECS execution role name"
}

variable "secret_arn" {
  type        = string
  description = "Secrets Manager secret ARN"
}

variable "region" {
  description = "Name of the region"
  type        = string
}

variable "post_pr_lambda_arn" {
  description = "Lambda ARN for post PR action trigger"
  type        = string
}