terraform {
  backend "s3" {
    bucket = "terraform-vsv"
    key    = "dev/eks-deploy.tfstate"
    region = "us-east-1"
    encrypt = true
    profile = "personal"
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}