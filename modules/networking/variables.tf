variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC"
}

variable "create_subnets" {
  type        = bool
  default     = true
  description = "Whether Terraform should create subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for public and private subnets"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix appended to resource names"
}