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