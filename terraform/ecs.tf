# ecs.tf
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  tags = {
    Name        = "${var.app_name}-cluster"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "weather_fetcher" {
  family                   = "${var.app_name}-fetcher"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.weather_fetcher_task.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "weather-fetcher"
      image     = "${var.docker_registry}/weather-fetcher:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "OPENWEATHER_API_KEY"
          value = var.openweather_api_key
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "fetcher"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "weather_processor" {
  family                   = "${var.app_name}-processor"
  task_role_arn            = aws_iam_role.weather_processor_task.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "weather-processor"
      image     = "${var.docker_registry}/weather-processor:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5001
          hostPort      = 5001
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "processor"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "weather_fetcher" {
  name            = "${var.app_name}-fetcher-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.weather_fetcher.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "weather_processor" {
  name            = "${var.app_name}-processor-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.weather_processor.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}
