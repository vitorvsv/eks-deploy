module "eks" {
  source = "git::https://github.com/vitorvsv/eks-terraform.git?ref=v1.0.0"
  project = "eks-deploy"
  region = "us-east-1"
  cidr_block = "10.0.0.0/16"
  tags = {
    Environment = "dev"
    Project = "eks-deploy"
    Owner = "vitorvsv"
    CostCenter = "Engineering"
  }
}