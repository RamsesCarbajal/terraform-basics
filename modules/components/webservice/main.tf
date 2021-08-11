resource "aws_alb" "default" {
  name = var.base-name
  tags = var.standard-tags

  subnets = [
    var.subnet-a-id,
    var.subnet-b-id,
  ]

  security_groups = [
    var.public-http-security-group-id
  ]
}

resource "aws_alb_target_group" "default" {
  name        = var.base-name
  port        = 80
  protocol    = "HTTP"
  tags        = var.standard-tags
  target_type = "ip"
  vpc_id      = var.vpc-id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = var.healthcheck-matcher
    path                = var.health-path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 5
  }
}

resource "aws_alb_listener" "default-http" {
  load_balancer_arn = aws_alb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "default-https" {
  load_balancer_arn = aws_alb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate-arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default.arn
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.base-name}"
  retention_in_days = 3
  tags              = var.standard-tags
}

variable "app_environments_vars_test" {
  type        = list(map(string))
  description = "environment varibale needed by the application"
  default = []
}

resource "aws_ecs_task_definition" "default" {
  container_definitions = jsonencode(
    [
      merge(
        {
          cpu         = 0
          environment = var.app_environments_vars_test
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
          name = var.base-name
          secrets = var.secrets_environment
          portMappings = [
            {
              containerPort = var.app-port
              hostPort      = var.app-port
              protocol      = "tcp"
            },
          ]
          mountPoints = [for it in keys(var.bind-volumes) : {
            sourceVolume  = it,
            containerPath = lookup(var.bind-volumes, it).containerPath,
            readonly      = try(lookup(var.bind-volumes, it).readonly, false),
          }]
        },
        try({ command = tolist(var.command) }, {}),
        try({ entrypoint = tolist(var.entrypoint) }, {}),
        var.internal-health-command-enabled ? {
          healthCheck = {
            "command" : ["CMD-SHELL", var.internal-health-command != null ? var.internal-health-command : "curl -f http://localhost:${var.app-port}${var.health-path} || exit 1"]
            "interval" : 30
            "retries" : 3
            "timeout" : 5
            "startPeriod" : 5
        } } : {}
      ),
    ]
  )
  cpu                = "256"
  execution_role_arn = "arn:aws:iam::565557057306:role/ecsTaskExecutionRole"
  family             = var.base-name
  memory             = var.memory
  network_mode       = "awsvpc"
  requires_compatibilities = [
    var.launch-type,
  ]
  tags          = var.standard-tags
  task_role_arn = "arn:aws:iam::565557057306:role/ecsTaskExecutionRole"


  dynamic "volume" {
    for_each = var.bind-volumes
    content {
      name      = volume.key
      host_path = volume.value.sourcePath
    }
  }
}

resource "aws_ecs_service" "default" {
  cluster                            = var.cluster-arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = var.enabled ? var.desired-instances : 0
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = var.healthcheck-grace-seconds
  launch_type                        = var.launch-type
  name                               = var.service-name

  platform_version = var.launch-type == "FARGATE" ? "LATEST" : null

  propagate_tags      = "SERVICE"
  scheduling_strategy = "REPLICA"
  tags                = var.standard-tags
  task_definition     = "${aws_ecs_task_definition.default.id}:${aws_ecs_task_definition.default.revision}"

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = var.base-name
    container_port   = var.app-port
    target_group_arn = aws_alb_target_group.default.id
  }

  network_configuration {
    assign_public_ip = var.launch-type == "FARGATE" ? true : false
    security_groups = [
      var.internal-security-group,
    ]
    subnets = [
      var.subnet-a-id,
      var.subnet-b-id,
    ]
  }

  depends_on = [
    aws_alb.default
  ]
}
