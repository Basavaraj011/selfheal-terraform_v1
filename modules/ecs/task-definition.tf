resource "aws_ecs_task_definition" "this" {
  family                   = "task-${var.resource_suffix}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "container-selfheal"
      image     = var.image_url
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/healthz || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      
    
      secrets = [
        { name = "PROJECT_DB_CONFIG", valueFrom = "${var.secret_arn}:PROJECT_DB_CONFIG::" },
        { name = "AZ_AI_API_KEY", valueFrom = "${var.secret_arn}:AZ_AI_API_KEY::" },
        { name = "AZ_END_POINT", valueFrom = "${var.secret_arn}:AZ_END_POINT::" },
        { name = "SERVICE_LINE", valueFrom = "${var.secret_arn}:SERVICE_LINE::" },
        { name = "BRAND", valueFrom = "${var.secret_arn}:BRAND::" },
        { name = "PROJECT", valueFrom = "${var.secret_arn}:PROJECT::" },
        { name = "AI_MODEL", valueFrom = "${var.secret_arn}:AI_MODEL::" },
        { name = "AI_PROVIDER", valueFrom = "${var.secret_arn}:AI_PROVIDER::" },
        { name = "AI_API_KEY", valueFrom = "${var.secret_arn}:AI_API_KEY::" },
        { name = "DATABASE_URL", valueFrom = "${var.secret_arn}:DATABASE_URL::" },
        { name = "JIRA_URL", valueFrom = "${var.secret_arn}:JIRA_URL::" },
        { name = "JIRA_USERNAME", valueFrom = "${var.secret_arn}:JIRA_USERNAME::" },
        { name = "JIRA_API_TOKEN", valueFrom = "${var.secret_arn}:JIRA_API_TOKEN::" },
        { name = "TEAMS_WORKFLOW_URL", valueFrom = "${var.secret_arn}:TEAMS_WORKFLOW_URL::" },
        { name = "BB_PROVIDER", valueFrom = "${var.secret_arn}:BB_PROVIDER::" },
        { name = "BB_BASE_URL", valueFrom = "${var.secret_arn}:BB_BASE_URL::" },
        { name = "BB_USERNAME", valueFrom = "${var.secret_arn}:BB_USERNAME::" },
        { name = "API_USERNAME", valueFrom = "${var.secret_arn}:API_USERNAME::" },
        { name = "GIT_USERNAME", valueFrom = "${var.secret_arn}:GIT_USERNAME::" },
        { name = "BB_WORKSPACE", valueFrom = "${var.secret_arn}:BB_WORKSPACE::" },
        { name = "BB_PROJECT", valueFrom = "${var.secret_arn}:BB_PROJECT::" },
        { name = "BB_REPO_SLUG", valueFrom = "${var.secret_arn}:BB_REPO_SLUG::" },
        { name = "BB_API_TOKEN", valueFrom = "${var.secret_arn}:BB_API_TOKEN::" },
        { name = "BB_REVIEWERS", valueFrom = "${var.secret_arn}:BB_REVIEWERS::" },
        { name = "VECTOR_STORE_TYPE", valueFrom = "${var.secret_arn}:VECTOR_STORE_TYPE::" },
        { name = "VECTOR_STORE_API_KEY", valueFrom = "${var.secret_arn}:VECTOR_STORE_API_KEY::" },
        { name = "WEB_APP_HOST", valueFrom = "${var.secret_arn}:WEB_APP_HOST::" },
        { name = "WEB_APP_PORT", valueFrom = "${var.secret_arn}:WEB_APP_PORT::" },
        { name = "WEB_APP_DEBUG", valueFrom = "${var.secret_arn}:WEB_APP_DEBUG::" },
        { name = "LOG_LEVEL", valueFrom = "${var.secret_arn}:LOG_LEVEL::" },
        { name = "TEAMS_OUTGOING_HMAC_SECRET", valueFrom = "${var.secret_arn}:TEAMS_OUTGOING_HMAC_SECRET::" },
        { name = "PORT", valueFrom = "${var.secret_arn}:PORT::" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}