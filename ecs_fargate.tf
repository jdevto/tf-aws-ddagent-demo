resource "aws_ecs_cluster" "fargate" {
  name = "${local.name}-fargate"
}

# ECS Task Definition for Web Application with Datadog Sidecar
resource "aws_ecs_task_definition" "webapp_fargate" {
  family                   = "${local.name}-webapp-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/${local.name}-fargate/ecs/service/webapp"
          awslogs-region        = "${data.aws_region.current.name}"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      essential = true
      environment = [
        { name = "DD_API_KEY", value = "${var.dd_api_key}" },
        { name = "DD_SITE", value = "datadoghq.com" },
        { name = "DD_LOG_LEVEL", value = "info" },
        { name = "ECS_FARGATE", value = "true" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/${local.name}-fargate/ecs/service/ddagent"
          awslogs-region        = "${data.aws_region.current.name}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        retries     = 3
        command     = ["CMD-SHELL", "agent health"]
        timeout     = 5
        interval    = 30
        startPeriod = 15
      }
    }
  ])
}

# ECS Service for Web Application running on AWS Fargate
resource "aws_ecs_service" "webapp_fargate" {
  name            = "${local.name}-webapp-fargate"
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.webapp_fargate.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.webapp.id]
  }

  depends_on = [
    aws_cloudwatch_log_group.webapp_fargate
  ]
}
