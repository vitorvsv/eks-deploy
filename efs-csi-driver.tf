data "aws_caller_identity" "current" {}

locals {
  eks_oidc_provider_id = split("/", data.aws_eks_cluster.this.identity[0].oidc[0].issuer)[4]
}

resource "aws_iam_role" "efs_csi_driver_role" {
  name = "${local.project}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${local.region}.amazonaws.com/id/${local.eks_oidc_provider_id}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${local.region}.amazonaws.com/id/${local.eks_oidc_provider_id}:aud" = "sts.amazonaws.com"
            "oidc.eks.${local.region}.amazonaws.com/id/${local.eks_oidc_provider_id}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${local.project}-efs-csi-driver-role"
  })
}

resource "aws_iam_policy" "efs_csi_driver" {
  name        = "${local.project}-efs-csi-driver"
  description = "EFS CSI controller permissions scoped to this project's file system"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDescribe"
        Effect = "Allow"
        Action = [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "ec2:DescribeAvailabilityZones",
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowCreateAccessPoint"
        Effect   = "Allow"
        Action   = ["elasticfilesystem:CreateAccessPoint"]
        Resource = aws_efs_file_system.this.arn
        Condition = {
          StringLike = {
            "aws:RequestTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      },
      {
        Sid      = "AllowTagAccessPoint"
        Effect   = "Allow"
        Action   = ["elasticfilesystem:TagResource"]
        Resource = "arn:aws:elasticfilesystem:${local.region}:${data.aws_caller_identity.current.account_id}:access-point/*"
        Condition = {
          StringLike = {
            "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      },
      {
        Sid      = "AllowDeleteAccessPoint"
        Effect   = "Allow"
        Action   = ["elasticfilesystem:DeleteAccessPoint"]
        Resource = "arn:aws:elasticfilesystem:${local.region}:${data.aws_caller_identity.current.account_id}:access-point/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachments_exclusive" "efs_csi_driver_role_attach_policy" {
  role_name = aws_iam_role.efs_csi_driver_role.name
  policy_arns = [
    aws_iam_policy.efs_csi_driver.arn,
  ]
}

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name                = data.aws_eks_cluster.this.name
  addon_name                  = "aws-efs-csi-driver"
  service_account_role_arn    = aws_iam_role.efs_csi_driver_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.tags

  depends_on = [aws_efs_mount_target.this]
}
