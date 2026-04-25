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

variable "existing_public_subnet_ids" {
  type        = list(string)
  description = "Existing private subnet IDs (used only when create_subnets = false)"
  default     = []
}

variable "ecs_existing_private_subnet_ids" {
  type        = list(string)
  description = "Existing private subnet IDs (used only when create_subnets = false)"
  default     = []
}

variable "image_url" {
  type        = string
  description = "Flask container image URL"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "server_cert_path" {
  description = "Path to Client VPN server certificate (.crt)"
  type        = string
}

variable "server_key_path" {
  description = "Path to Client VPN server private key (.key)"
  type        = string
  sensitive   = true
}

variable "ca_cert_path" {
  description = "Path to client root CA certificate (.crt)"
  type        = string
}

variable "ca_key_path" {
  description = "Path to client root CA private key (.key)"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "existing_private_route_table_ids" {
  type = list(string)
}

