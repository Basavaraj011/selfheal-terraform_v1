resource "aws_lb_target_group" "ecs" {
  name        = "tg-${var.resource_suffix}"
  port        = 3978
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "tg-${var.resource_suffix}"
  }
}