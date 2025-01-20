#ECS task defintions
# API Gateway Task Definition
resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "weather-app-gateway"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn  # Reference to the role you already have
  task_role_arn           = aws_iam_role.ecs_task_role.arn           # Reference to the role you already have

  container_definitions = jsonencode([
    {
      name  = "api-gateway"
      image = "${var.api_gateway_repository_url}:latest"
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "FETCHER_SERVICE_URL"
          value = "http://weather-fetcher.weather.local:5000"
        },
        {
          name  = "PROCESSOR_SERVICE_URL"
          value = "http://weather-processor.weather.local:5000"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/weather-app-gateway"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_task_definition" "weather_fetcher" {
  family                   = "weather-app-fetcher"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn  # Reference to the role you already have
  task_role_arn           = aws_iam_role.ecs_task_role.arn  
  
  container_definitions = jsonencode([
    {
      name  = "weather-fetcher"
      image = "${var.weather_fetcher_repository_url}:latest"
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "PROCESSOR_SERVICE_URL"
          value = "http://weather-processor.weather.local:5000"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/weather-app-fetcher"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_task_definition" "weather_processor" {
  family                   = "weather-app-processor"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn  # Reference to the role you already have
  task_role_arn           = aws_iam_role.ecs_task_role.arn  
  
  container_definitions = jsonencode([
    {
      name  = "weather-processor"
      image = "${var.weather_processor_repository_url}:latest"
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "FETCHER_SERVICE_URL"
          value = "http://weather-fetcher.weather.local:5000"
        },
        
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/weather-app-processor"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}



