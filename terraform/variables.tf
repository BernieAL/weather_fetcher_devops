# variables.tf
variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g. prod, dev, staging)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "weather-app"
}

variable "docker_registry" {
  description = "Docker registry (e.g., your Docker Hub username)"
  type        = string
}

variable "openweather_api_key" {
  description = "OpenWeather API Key"
  type        = string
}
