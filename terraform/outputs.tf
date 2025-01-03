# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_task_revision_fetcher" {
  description = "Latest revision of weather fetcher task definition"
  value       = aws_ecs_task_definition.weather_fetcher.revision
}

output "ecs_task_revision_processor" {
  description = "Latest revision of weather processor task definition"
  value       = aws_ecs_task_definition.weather_processor.revision
}

output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.main.execution_arn}/test/GET"
}

output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}