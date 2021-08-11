resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.base-name}"
  retention_in_days = 3
  tags              = var.standard-tags
}

resource "aws_ecs_task_definition" "default" {
  container_definitions = jsonencode(
    [
      {
        cpu         = 0
        environment = var.environment
        essential   = true
        image       = "${var.repository-url}:${var.deployment-tag}"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.default.name
            awslogs-region        = var.aws-region
            awslogs-stream-prefix = "ecs"
          }
        }
        name         = var.base-name
        portMappings = []
        secrets = var.secrets
      },
    ]
  )
  cpu                = "256"
  execution_role_arn = "arn:aws:iam::565557057306:role/ecsTaskExecutionRole"
  family             = var.base-name
  memory             = var.memory
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  tags          = var.standard-tags
  task_role_arn = "arn:aws:iam::565557057306:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "default" {
  cluster                            = var.cluster-arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = var.desired-instances
  enable_ecs_managed_tags            = true
  launch_type                        = "FARGATE"
  name                               = var.service-name
  platform_version                   = "LATEST"
  propagate_tags                     = "SERVICE"
  scheduling_strategy                = "REPLICA"
  tags                               = var.standard-tags
  task_definition                    = "${aws_ecs_task_definition.default.id}:${aws_ecs_task_definition.default.revision}"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      var.internal-security-group-id,
    ]
    subnets = [
      var.subnet-a-id,
      var.subnet-b-id,
    ]
  }
}