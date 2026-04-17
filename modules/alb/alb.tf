resource "aws_lb" "this" {
  name               = "alb-${var.resource_suffix}"
  internal           = true
  load_balancer_type = "application"

  subnets         = var.subnet_ids
  security_groups = [var.alb_security_group_id]

  tags = {
    Name = "alb-${var.resource_suffix}"
  }
}

output "listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "ARN of the ALB HTTP listener"
}

