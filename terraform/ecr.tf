# ECR Repositories
resource "aws_ecr_repository" "api_gateway" {
  name                 = "weather-app-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
    Service     = "api-gateway"
  }
}

resource "aws_ecr_repository" "weather_fetcher" {
  name                 = "weather-app-fetcher"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
    Service     = "weather-fetcher"
  }
}


resource "aws_ecr_repository" "weather_processor" {
  name                 = "weather-app-processor"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
    Service     = "weather-processor"
  }
}


#Lifecycle Policies - Keep last 30 images, remove untagged images after 7 days
resource "aws_ecr_lifecycle_policy" "api_gateway" {
  repository = aws_ecr_repository.api_gateway.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

#Apply same lifecycle policy to other repositories
resource "aws_ecr_lifecycle_policy" "weather_fetcher" {
  repository = aws_ecr_repository.weather_fetcher.name
  policy     = aws_ecr_lifecycle_policy.api_gateway.policy
}

resource "aws_ecr_lifecycle_policy" "weather_processor" {
  repository = aws_ecr_repository.weather_processor.name
  policy     = aws_ecr_lifecycle_policy.api_gateway.policy
}

# ECR Repository Policy - Allow ECS tasks to pull images
resource "aws_ecr_repository_policy" "api_gateway" {
  repository = aws_ecr_repository.api_gateway.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "weather_fetcher" {
  repository = aws_ecr_repository.weather_fetcher.name
  policy     = aws_ecr_repository_policy.api_gateway.policy
}

resource "aws_ecr_repository_policy" "weather_processor" {
  repository = aws_ecr_repository.weather_processor.name
  policy     = aws_ecr_repository_policy.api_gateway.policy
}

# Outputs for easy reference
output "repository_urls" {
  value = {
    api_gateway       = aws_ecr_repository.api_gateway.repository_url
    weather_fetcher   = aws_ecr_repository.weather_fetcher.repository_url
    weather_processor = aws_ecr_repository.weather_processor.repository_url
  }
  description = "ECR repository URLs for each service"
}