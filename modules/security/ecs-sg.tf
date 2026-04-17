resource "aws_security_group" "ecs" {
  name        = "ecs_${var.resource_suffix}"
  description = "Security group for ECS tasks running Flask"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB to ECS tasks"
    from_port       = 3978
    to_port         = 3978
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_${var.resource_suffix}"
  }
}