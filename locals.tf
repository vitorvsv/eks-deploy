locals {
  project    = "eks-deploy"
  region     = "us-east-1"
  cidr_block = "10.0.0.0/16"
  profile    = "personal"

  github_repository = "vitorvsv/eks-deploy"
  eks_cluster_name  = "${local.project}-eks-cluster"

  tags = {
    Environment = "dev"
    Project     = local.project
    Owner       = "vitorvsv"
    CostCenter  = "Engineering"
  }
}
