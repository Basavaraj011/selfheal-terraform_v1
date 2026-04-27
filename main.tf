module "security" {
  source = "./modules/security"

  vpc_id           = var.vpc_id
  vpc_cidr         = var.vpc_cidr
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

  ecs_subnet_ids         = local.ecs_private_subnet_id
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

  resource_suffix     = local.resource_suffix
  execution_role_name = "ecs-execution-${local.resource_suffix}"
  secret_arn          = module.app_secrets.secret_arn
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
      DATABASE_URL                 = "Driver={ODBC Driver 18 for SQL Server};Server=selfheal-db.ccpssgke4tiv.us-east-1.rds.amazonaws.com;Database=AI_PredictiveRecoveryDB;Uid=admin;Pwd=Admin-123;Encrypt=no;TrustServerCertificate=yes;"
      JIRA_URL                     = "https://basums.atlassian.net"
      JIRA_USERNAME                = "basums011@gmail.com"
      JIRA_API_TOKEN               = "ATATT3xFfGF0_um4-nONeANhKFOkGpjDkwA7_6OY2adR7dLSg43hYmHf3Pw5XWonKAxs_QZq5xJ6JPphLRlXW1Pq0qPccqvIUPEizwsyu4DxD2zMfGsxJeiLOwGpj4FlAz5nCfh9pO8HApVizjCFcXbL9VoOHLZya3ZW2tkTCinlcwOJxIICY08=0B0F4D9F"
      TEAMS_WORKFLOW_URL           = "https://default6e8992ec76d54ea58eaeb0c5e55874.9a.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/91ceb8dbdda245848a65a30eddc648dd/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ceUWS3lwr-AOJz6-sdyhAjXKNAG1Pd3jWtVBWw6N9xw"
      BB_PROVIDER                  = "cloud"
      BB_BASE_URL                  = "https://api.bitbucket.org/2.0"
      BB_USERNAME                  = "basums011"
      API_USERNAME                 = "basums011@gmail.com"
      GIT_USERNAME                 = "basums011"
      BB_WORKSPACE                 = "error_handlling_system"
      BB_PROJECT                   = "error_handling_system"
      BB_REPO_SLUG                 = "python-worker"
      BB_API_TOKEN                 = "ATATT3xFfGF0g0u9z4wFUnYh0AlyFUOj5Injvh1hMfde4rtUbJSEEOfDOzpkwrhgSfb2um_5hgY2wUW_iHJAARXBlkKpg1ClpRhhzoxODo3iixrjsqqlvvU7Rfm90GJ9Fq3OCdUPt-hxrew9cOZPfkPsZtGBGeMC8q5X1P5ZOTM90Lqvu1WBQAc=03E6FF10"
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

module "rds" {
  source = "./modules/rds"

  db_username = var.db_username
  db_password = var.db_password
  
  rds_security_group_id = module.security.rds_security_group_id
  private_subnet_ids = local.private_subnet_ids
}

module "client_vpn" {
  source = "./modules/client_vpn"

  vpc_id            = var.vpc_id
  vpc_cidr          = var.vpc_cidr
  private_subnet_id = local.private_subnet_ids[0]

  server_cert_path = "${path.module}/certs/server.crt"
  server_key_path  = "${path.module}/certs/server.key"
  ca_cert_path     = "${path.module}/certs/ca.crt"
  ca_key_path      = "${path.module}/certs/ca.key"
}

module "lambda_s3_trigger" {
  source = "./modules/lambda"

  lambda_role_arn = module.iam.lambda_ecs_trigger_role_arn
  lambda_filename = "modules/lambda/lambda.zip"
  ecs_cluster_name      = module.ecs.cluster_name
  task_definition_family_name   = module.ecs.task_definition_family_name
  container_name        = module.ecs.container_name
  private_subnet_ids    = local.private_subnet_ids
  ecs_security_group_id = module.security.ecs_security_group_id
}

module "s3_error_logs" {
  source = "./modules/s3"

  bucket_name = "error-log-bucket-arun1"
  lambda_arn  = module.lambda_s3_trigger.lambda_arn
}
