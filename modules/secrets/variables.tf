variable "name" {
  description = "Secrets Manager secret name"
  type        = string
}

variable "env_vars" {
  description = "Environment variables map (from .env)"
  type        = map(string)
}