resource "aws_lambda_function" "this" {
  function_name = "s3-to-ecs-trigger"
  role          = var.lambda_role_arn
  runtime       = "python3.11"
  handler       = "handler.lambda_handler"
  timeout       = 60

  filename         = var.lambda_filename
  source_code_hash = filebase64sha256(var.lambda_filename)

  
  environment {
    variables = {
      ECS_CLUSTER_NAME     = var.ecs_cluster_name
      TASK_DEFINITION_NAME = var.task_definition_family_name
      CONTAINER_NAME       = var.container_name
      ECS_SECURITY_GROUP   = var.ecs_security_group_id
      ECS_SUBNETS          = join(",", slice(var.private_subnet_ids, 0, 2))
    }
  }

}