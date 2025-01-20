variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  type        = string
}

variable "api_gateway_repository_url" {
  description = "ECR Repository URL for API Gateway"
  type        = string
}

variable "weather_fetcher_repository_url" {
  description = "ECR Repository URL for Weather Fetcher"
  type        = string
}

variable "weather_processor_repository_url" {
  description = "ECR Repository URL for Weather Processor"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}