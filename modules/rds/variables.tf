variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID for RDS"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS"
}
