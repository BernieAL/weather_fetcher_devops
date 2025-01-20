resource "aws_iam_user_policy" "terraform_deployer_policy" {
  name = "TerraformECSDeploymentPolicy"
  user = "terraform-deployer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "logs:*",
          "apigateway:*",
          "sns:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:*"  # Changed to wildcard to include all ECR permissions
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::*:role/ECSTaskExecutionRole"
        Condition = {
          StringEquals = {
            "iam:PassedToService": "ecs-tasks.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = "iam:*"
        Resource = "*"
      }
    ]
  })
}