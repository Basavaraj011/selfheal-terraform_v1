############################################
# Interface VPC Endpoints for ECS
############################################

# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.ap-south-1.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.security.ecs_security_group_id]
#   private_dns_enabled = true

#   tags = {
#     Name = "vpce-secretsmanager"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.ap-south-1.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.security.ecs_security_group_id]
#   private_dns_enabled = true

#   tags = {
#     Name = "vpce-ecr-api"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.ap-south-1.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.security.ecs_security_group_id]
#   private_dns_enabled = true

#   tags = {
#     Name = "vpce-ecr-dkr"
#   }
# }

# resource "aws_vpc_endpoint" "logs" {
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.ap-south-1.logs"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.security.ecs_security_group_id]
#   private_dns_enabled = true

#   tags = {
#     Name = "vpce-cloudwatch-logs"
#   }
# }

# resource "aws_vpc_endpoint" "sts" {
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.ap-south-1.sts"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = local.private_subnet_ids
#   security_group_ids  = [module.security.ecs_security_group_id]
#   private_dns_enabled = true

#   tags = {
#     Name = "vpce-sts"
#   }
# }
# ############################################
# # S3 Gateway Endpoint (required for ECR)
# ############################################

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-south-1.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = local.private_route_table_ids

#   tags = {
#     Name = "vpce-s3"
#   }
# }