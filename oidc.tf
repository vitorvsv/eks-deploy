data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_eks_cluster" "this" {
  name = local.eks_cluster_name
}

resource "aws_iam_role" "github_actions" {
  name = "${local.project}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${local.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${local.project}-github-actions"
  })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "${local.project}-github-actions"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "EcrPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
        ]
        Resource = [for repo in aws_ecr_repository.this : repo.arn]
      },
      {
        Sid      = "EksDescribe"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = data.aws_eks_cluster.this.arn
      },
      {
        Sid    = "SecretsRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          aws_secretsmanager_secret.auth_api_token_key.arn,
          aws_secretsmanager_secret.users_api_mongodb.arn,
          aws_secretsmanager_secret.tasks_api_mongodb.arn,
        ]
      },
      {
        Sid      = "EfsDescribe"
        Effect   = "Allow"
        Action   = ["elasticfilesystem:DescribeFileSystems"]
        Resource = "*"
      },
    ]
  })
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = data.aws_eks_cluster.this.name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  tags = local.tags
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = aws_eks_access_entry.github_actions.cluster_name
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

output "github_actions_role_arn" {
  description = "IAM role ARN to set as GitHub secret AWS_OIDC_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "eks_cluster_name" {
  description = "EKS cluster name to set as GitHub secret EKS_CLUSTER_NAME"
  value       = data.aws_eks_cluster.this.name
}
