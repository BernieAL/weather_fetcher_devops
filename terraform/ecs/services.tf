# First keep your existing namespace
resource "aws_service_discovery_private_dns_namespace" "weather" {
  name        = "weather.local"
  description = "Weather services private DNS namespace"
  vpc         = var.vpc_id
}

# Then add all three service discoveries (fetcher, processor, and gateway)
resource "aws_service_discovery_service" "weather_fetcher" {
  name = "weather-fetcher"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.weather.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "weather_processor" {
  name = "weather-processor"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.weather.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "api_gateway" {
  name = "api-gateway"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.weather.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}


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
    container_port   = 5002
  }

    service_registries {
    registry_arn = aws_service_discovery_service.api_gateway.arn  # Changed from weather_fetcher to api_gateway
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

   service_registries {
    registry_arn = aws_service_discovery_service.weather_fetcher.arn
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
  service_registries {
    registry_arn = aws_service_discovery_service.weather_processor.arn
  }
}

# Update security group to allow internal communication
resource "aws_security_group_rule" "allow_internal" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5001
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id        = aws_security_group.ecs_tasks.id
}