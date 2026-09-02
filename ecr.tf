locals {
  ecr_repositories = [
    "eks-deploy-auth-api",
    "eks-deploy-users-api",
    "eks-deploy-tasks-api",
  ]

  common_tags = {
    Environment = "dev"
    Project     = "eks-deploy"
    Owner       = "vitorvsv"
    CostCenter  = "Engineering"
  }
}

resource "aws_ecr_repository" "this" {
  for_each = toset(local.ecr_repositories)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_urls" {
  description = "URLs dos repositórios ECR"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}
