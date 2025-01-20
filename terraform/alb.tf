# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "weather-app-alb-sg"
  description = "Security group for weather application ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "weather-app-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "weather-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "weather-app-alb"
  }
}

# API Gateway Target Group (Main entry point)
resource "aws_lb_target_group" "api_gateway" {
  name        = "weather-api-gateway-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    interval           = 30
    protocol           = "HTTP"
    matcher            = "200"
    timeout            = 5
    path              = "/health"
    unhealthy_threshold = 2
    port              = 5000
  }
}

# Main HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway.arn
  }
}

# Listener Rule for API Paths
resource "aws_lb_listener_rule" "api_gateway" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway.arn
  }

  condition {
    path_pattern {
      values = ["/weather/*", "/raw/*"]
    }
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The DNS name of the application load balancer"
}