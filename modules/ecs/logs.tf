resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/task-${var.resource_suffix}"
  retention_in_days = 7
}