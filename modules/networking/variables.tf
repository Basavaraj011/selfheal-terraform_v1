variable "vpc_id" {
  type        = string
  description = "VPC ID where subnets will be created"
}

variable "create_subnets" {
  type        = bool
  default     = true
  description = "Controls whether subnets should be created"
}

variable "az" {
  type        = string
  description = "Single availability zone to use (e.g. ap-south-1a)"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for private subnet"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix appended to resource names (e.g., selfheal)"
}