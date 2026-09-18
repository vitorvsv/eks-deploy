data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.this.vpc_config[0].vpc_id]
  }

  tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_efs_file_system" "this" {
  creation_token   = "${local.project}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(local.tags, {
    Name = "${local.project}-efs"
  })
}

resource "aws_security_group" "efs" {
  name        = "${local.project}-efs"
  description = "NFS from the EKS cluster security group to EFS mount targets"
  vpc_id      = data.aws_eks_cluster.this.vpc_config[0].vpc_id

  tags = merge(local.tags, {
    Name = "${local.project}-efs"
  })
}

resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  security_group_id            = aws_security_group.efs.id
  description                  = "NFS from EKS cluster security group"
  referenced_security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(data.aws_subnets.private.ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_file_system_policy" "this" {
  file_system_id = aws_efs_file_system.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowMountViaMountTarget"
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
        ]
        Resource = aws_efs_file_system.this.arn
        Condition = {
          Bool = {
            "elasticfilesystem:AccessedViaMountTarget" = "true"
          }
        }
      },
      {
        Sid       = "EnforceInTransitEncryption"
        Effect    = "Deny"
        Principal = { AWS = "*" }
        Action    = ["*"]
        Resource  = aws_efs_file_system.this.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

output "efs_file_system_id" {
  description = "ID of the EFS file system used by the CSI driver"
  value       = aws_efs_file_system.this.id
}

output "efs_file_system_arn" {
  description = "ARN of the EFS file system used by the CSI driver"
  value       = aws_efs_file_system.this.arn
}
