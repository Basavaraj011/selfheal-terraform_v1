variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "alb_ingress_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed to access the ALB"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix appended to security group names (e.g., selfheal)"
}