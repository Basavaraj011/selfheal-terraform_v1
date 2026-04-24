output "cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "ECS cluster ID"
}

output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_definition_family_name" {
  value = aws_ecs_task_definition.this.family
}

output "container_name" {
  value = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].name
}
