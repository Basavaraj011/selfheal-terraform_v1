resource "aws_security_group" "rds" {
  name        = "rds-${var.resource_suffix}"
  description = "RDS SQL Server access from ECS only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SQL Server from ECS tasks"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ingress {
    description = "Temporary SSMS access from developer machine"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["49.200.116.246/32"]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-${var.resource_suffix}"
  }
}