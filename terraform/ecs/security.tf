# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "weather-app-ecs-tasks"
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = var.vpc_id
  
  # Rule for ALB to API Gateway
  ingress {
    from_port       = 5002  # API Gateway port
    to_port         = 5002
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Internal communication rules
  ingress {
    from_port       = 5000  # Weather Fetcher port
    to_port         = 5000
    protocol        = "tcp"
    self            = true  # Allows traffic from the same security group
  }

  ingress {
    from_port       = 5001  # Weather Processor port
    to_port         = 5001
    protocol        = "tcp"
    self            = true  # Allows traffic from the same security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "weather-app-ecs-tasks"
  }
}



