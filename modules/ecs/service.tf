resource "aws_ecs_service" "this" {
  name            = "service-${var.resource_suffix}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "container-selfheal"
    container_port   = var.container_port
  }

  depends_on = [
    var.alb_listener_arn
  ]
}