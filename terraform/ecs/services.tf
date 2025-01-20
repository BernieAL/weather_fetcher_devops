resource "aws_ecs_service" "api_gateway" {
  name            = "api-gateway-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_gateway.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "api-gateway"
    container_port   = 5000
  }
}

resource "aws_ecs_service" "weather_fetcher" {
  name            = "weather-fetcher-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.weather_fetcher.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

resource "aws_ecs_service" "weather_processor" {
  name            = "weather-processor-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.weather_processor.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}