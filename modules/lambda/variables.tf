########################################
# ECS integration variables
########################################

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster where the task will be run"
}

variable "task_definition_family_name" {
  type        = string
  description = "Name of the ECS task definition to run"
}

variable "container_name" {
  type        = string
  description = "Name of the container inside the task definition"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for running the ECS task"
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security group ID for the ECS task"
}

########################################
# Lambda packaging/runtime variables
########################################

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
  default     = "s3-to-ecs-trigger"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.11"
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 60
}

variable "lambda_filename" {
  type        = string
  description = "Path to the Lambda deployment zip file"
  default     = "lambda.zip"
}

variable "lambda_role_arn" {
  type = string
}
