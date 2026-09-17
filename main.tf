module "eks" {
  source     = "git::https://github.com/vitorvsv/eks-terraform.git?ref=v1.0.0"
  project    = local.project
  region     = local.region
  cidr_block = local.cidr_block
  tags       = local.tags
}
