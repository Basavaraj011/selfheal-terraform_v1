variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to use"
}

variable "availability_zones" {
  type        = list(string)
  description = "Single Availability Zone to use (e.g. ap-south-1a)"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR block for the public subnet (internet-facing)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR block for the private subnet (ECS, RDS)"
}

variable "create_subnets" {
  type        = bool
  description = "Whether Terraform should create subnets"
  default     = true
}

variable "existing_private_subnet_ids" {
  type        = list(string)
  description = "Existing private subnet IDs (used only when create_subnets = false)"
  default     = []
}

variable "image_url" {
  type        = string
  description = "Flask container image URL"
}
