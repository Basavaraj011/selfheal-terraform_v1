module "networking" {
  source = "./modules/networking"

  vpc_id               = var.vpc_id
  create_subnets       = var.create_subnets
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  resource_suffix      = local.resource_suffix
}

module "security" {
  source = "./modules/security"

  vpc_id           = var.vpc_id
  alb_ingress_cidr = ["10.0.0.0/16"]
  resource_suffix  = local.resource_suffix
}


module "alb" {
  source = "./modules/alb"

  vpc_id                = var.vpc_id
  subnet_ids            = local.private_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  resource_suffix       = local.resource_suffix
}

module "ecs" {
  source = "./modules/ecs"
  region = var.region
  cluster_name    = "selfheal-cluster"
  resource_suffix = local.resource_suffix
  secret_arn = module.app_secrets.secret_arn

  image_url      = local.image_url
  container_port = 3978
  cpu            = 256
  memory          = 512

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  subnet_ids            = local.private_subnet_ids
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
  source = "./modules/iam"

  resource_suffix      = local.resource_suffix
  execution_role_name  = "ecs-execution-${local.resource_suffix}"
  secret_arn           = module.app_secrets.secret_arn
}

module "apigw" {
  source = "./modules/apigw"

  subnet_ids        = local.private_subnet_ids
  security_group_id = module.security.alb_security_group_id
  alb_listener_arn  = module.alb.listener_arn
  resource_suffix   = local.resource_suffix
}

module "app_secrets" {
  source = "./modules/secrets"

  name = "selfheal/app/env"

  env_vars = {
      PROJECT_DB_CONFIG            = "{ \"sql_schema\": \"project_1\", \"sql_database\": \"AI_PredictiveRecoveryDB\" }"
      AZ_AI_API_KEY                = "aefafd40db70465aad5823001b4b015a"
      AZ_END_POINT                 = "https://ai-api-dev.dentsu.com"
      SERVICE_LINE                 = "cxm"
      BRAND                        = "merkle"
      PROJECT                      = "error-healing"
      AI_MODEL                     = "GPT-4.1"
      AI_PROVIDER                  = "azure_apim_chat"
      AI_API_KEY                   = "AI_API_KEY"
      DATABASE_URL                 = "Driver={ODBC Driver 13 for SQL Server};Server=IN-71S9R24\\SQLEXPRESS;Database=AI_PredictiveRecoveryDB;Trusted_Connection=yes;"
      JIRA_URL                     = "https://basums.atlassian.net"
      JIRA_USERNAME                = "basums011@gmail.com"
      JIRA_API_TOKEN               = "****"
      TEAMS_WORKFLOW_URL           = "https://..."
      BB_PROVIDER                  = "cloud"
      BB_BASE_URL                  = "https://api.bitbucket.org/2.0"
      BB_USERNAME                  = "basums011"
      API_USERNAME                 = "basums011@gmail.com"
      GIT_USERNAME                 = "basums011"
      BB_WORKSPACE                 = "error_handlling_system"
      BB_PROJECT                   = "error_handling_system"
      BB_REPO_SLUG                 = "python-worker"
      BB_API_TOKEN                 = "****"
      BB_REVIEWERS                 = "{504c3b62-8120-4f0c-a7bc-87800b9d6f70}"
      VECTOR_STORE_TYPE            = "pinecone"
      VECTOR_STORE_API_KEY         = "your_api_key"
      WEB_APP_HOST                 = "127.0.0.1"
      WEB_APP_PORT                 = "8000"
      WEB_APP_DEBUG                = "False"
      LOG_LEVEL                    = "INFO"
      TEAMS_OUTGOING_HMAC_SECRET   = "GId2wGzjqhnCrinvb+7KKaF1ozvrK3araPvQST7BltI="
      PORT                         = "3978"
    } 
}

module "permissions" {
  source = "./modules/permissions"

  task_role_name      = module.iam.task_role_name
  execution_role_name = module.iam.execution_role_name
  secret_arn          = module.app_secrets.secret_arn
}