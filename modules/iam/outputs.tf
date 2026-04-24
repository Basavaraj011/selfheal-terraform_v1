output "execution_role_arn" {
  value       = aws_iam_role.execution.arn
  description = "ECS execution role ARN"
}

output "task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "ECS task role ARN"
}

output "task_role_name" {
  value       = aws_iam_role.task.name
  description = "ECS task role name"
}

output "execution_role_name" {
  value = aws_iam_role.execution.name
}

output "lambda_ecs_trigger_role_arn" {
  value = aws_iam_role.lambda_ecs_trigger.arn
}