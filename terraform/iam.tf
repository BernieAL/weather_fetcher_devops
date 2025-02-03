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
          "sns:*",
          "servicediscovery:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:PutImage",
          "ecr:BatchDeleteImage",
          "ecr:ListImages",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
        Resource = [
          "arn:aws:ecr:us-east-1:058135280735:repository/*"
        ]
      },
      {
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:*"
        Resource = "*"
      }
    ]
  })
}

# Add this alongside your existing terraform_deployer_policy
resource "aws_iam_user_policy" "admin_user_policy" {
  name = "AdminUserPolicy"
  user = "admin-user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:*",
          "ecr:*",
          "ecs:*",
          "ec2:*"
        ]
        Resource = "*"
      }
    ]
  })
}