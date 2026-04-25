variable "region" {
  type        = string
  description = "AWS region for CloudWatch logs"
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix for ECS resources"
}
variable "image_url" {
  type        = string
  description = "Container image URL (ECR or Docker Hub)"
}

variable "container_port" {
  type        = number
  description = "Port on which Flask app listens"
}

variable "cpu" {
  type        = number
  description = "CPU units for the task"
}

variable "memory" {
  type        = number
  description = "Memory (MB) for the task"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS execution role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}
variable "ecs_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "secret_arn" {
  type        = string
  description = "Secrets Manager ARN for app env"
}
