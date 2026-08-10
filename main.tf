module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source = "./modules/security"

  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = module.vpc.vpc_cidr_block
  alb_ingress_cidr = [module.vpc.vpc_cidr_block]
  resource_suffix  = local.resource_suffix
}


module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnets
  alb_security_group_id = module.security.alb_security_group_id
  resource_suffix       = local.resource_suffix
}

module "ecs" {
  source = "./modules/ecs"
  region = var.region
  cluster_name    = "selfheal-cluster"
  resource_suffix = local.resource_suffix
  # secret_arn = module.app_secrets.secret_arn

  image_url      = local.image_url
  container_port = 3978
  cpu            = 256
  memory          = 512

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  ecs_subnet_ids         = [module.vpc.private_subnets[0]]
  ecs_security_group_id = module.security.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  alb_listener_arn      = module.alb.listener_arn
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "selfheal"
  resource_suffix = ""
}

module "iam" {
  source              = "./modules/iam"
  region              = var.region
  resource_suffix     = local.resource_suffix
  execution_role_name = "ecs-execution-${local.resource_suffix}"
  secret_arn          = module.app_secrets.secret_arn
  post_pr_lambda_arn = module.lambda_post_pr_action.lambda_arn
}

module "apigw" {
  source = "./modules/apigw"

  subnet_ids        = module.vpc.private_subnets
  security_group_id = module.security.alb_security_group_id
  alb_listener_arn  = module.alb.listener_arn
  resource_suffix   = local.resource_suffix
}

module "permissions" {
  source = "./modules/permissions"

  task_role_name      = module.iam.task_role_name
  execution_role_name = module.iam.execution_role_name
  secret_arn          = module.app_secrets.secret_arn
  bucket_name         = var.bucket_name
  region              = var.region
}

module "rds" {
  source = "./modules/rds"

  db_username = var.db_username
  db_password = var.db_password
  
  rds_security_group_id = module.security.rds_security_group_id
  private_subnet_ids = module.vpc.private_subnets
}

module "client_vpn" {
  source = "./modules/client_vpn"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  private_subnet_id = module.vpc.private_subnets[0]

  server_cert_path = "${path.module}/certs/server.crt"
  server_key_path  = "${path.module}/certs/server.key"
  ca_cert_path     = "${path.module}/certs/ca.crt"
  ca_key_path      = "${path.module}/certs/ca.key"
}

module "lambda_s3_trigger" {
  source = "./modules/lambda"

  function_name = "s3-to-ecs-trigger"

  lambda_role_arn = module.iam.lambda_ecs_trigger_role_arn
  lambda_filename = "modules/lambda/lambda.zip"
  lambda_handler    = "handler.lambda_handler"
  ecs_cluster_name            = module.ecs.cluster_name
  task_definition_family_name = module.ecs.task_definition_family_name
  container_name              = module.ecs.container_name

  private_subnet_ids    = module.vpc.private_subnets
  ecs_security_group_id = module.security.ecs_security_group_id
}

module "lambda_post_pr_action" {
  source = "./modules/lambda"

  function_name = "post-pr-actions-trigger"

  lambda_role_arn = module.iam.lambda_ecs_trigger_role_arn
  lambda_filename = "modules/lambda/lambda_post_pr_actions.zip"
  lambda_handler    = "handler_post_pr_actions.lambda_handler"
  ecs_cluster_name            = module.ecs.cluster_name
  task_definition_family_name = module.ecs.task_definition_family_name
  container_name              = module.ecs.container_name

  private_subnet_ids    = module.vpc.private_subnets
  ecs_security_group_id = module.security.ecs_security_group_id
}

module "lambda_selfheal_retry" {
  source = "./modules/lambda"

  function_name = "selfheal_retry"

  lambda_role_arn = module.iam.lambda_ecs_trigger_role_arn
  lambda_filename = "modules/lambda/lambda_selfheal_retry.zip"
  lambda_handler    = "handler_selfheal_retry.lambda_handler"
  ecs_cluster_name            = module.ecs.cluster_name
  task_definition_family_name = module.ecs.task_definition_family_name
  container_name              = module.ecs.container_name

  private_subnet_ids    = module.vpc.private_subnets
  ecs_security_group_id = module.security.ecs_security_group_id
}

module "s3_error_logs" {
  source = "./modules/s3"

  bucket_name = var.bucket_name
  lambda_arn  = module.lambda_s3_trigger.lambda_arn
}
