variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for VPC Link"
}

variable "security_group_id" {
  type        = string
  description = "Security group for API Gateway VPC Link"
}

variable "alb_listener_arn" {
  type        = string
  description = "ALB listener ARN to integrate with"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix for API Gateway resources"
}