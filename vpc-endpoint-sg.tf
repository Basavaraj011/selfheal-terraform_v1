data "aws_vpc_endpoint" "secretsmanager" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-south-1.secretsmanager"
}

resource "aws_security_group_rule" "vpce_https_from_ecs" {
  for_each = data.aws_vpc_endpoint.secretsmanager.security_group_ids

  type              = "ingress"
  security_group_id = each.value

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  source_security_group_id = module.security.ecs_security_group_id

  description = "Allow ECS tasks to access Secrets Manager via VPC endpoint over HTTPS"
}