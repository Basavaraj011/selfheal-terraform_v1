output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private subnet IDs created by the module"
}