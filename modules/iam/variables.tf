
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
