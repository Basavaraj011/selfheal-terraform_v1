variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID for Client VPN association"
}

variable "client_cidr_block" {
  type        = string
  description = "CIDR block assigned to VPN clients"
  default     = "10.100.0.0/22"
}

variable "server_cert_path" {
  type        = string
  description = "Path to Client VPN server certificate"
}

variable "server_key_path" {
  type        = string
  description = "Path to Client VPN server private key"
  sensitive   = true
}

variable "ca_cert_path" {
  type        = string
  description = "Path to client root CA certificate"
}

variable "ca_key_path" {
  type        = string
  description = "Path to client root CA private key"
  sensitive   = true
}