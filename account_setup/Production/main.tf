module "vpc" {
  source            = "../../aws_modules/vpc"
  vpc_cidr          = var.vpc_cidr
  availability_zone = var.availability_zone
  cluster_name      = var.cluster_name
}

module "eks" {
  source          = "../../aws_modules/eks"
  aws_access_key  = var.aws_access_key
  aws_secret_key  = var.aws_secret_key
  region          = var.region
  cluster_name    = var.cluster_name
  private_subnet1 = module.vpc.private_subnet1
  private_subnet2 = module.vpc.private_subnet2
  public_subnet1  = module.vpc.public_subnet1
  public_subnet2  = module.vpc.public_subnet2
}

module "fargate" {
  source                   = "../../aws_modules/fargate"
  cluster_name             = var.cluster_name
  endpoint                 = module.eks.endpoint
  certificate              = module.eks.kubeconfig-certificate-authority-data
  private_subnet1          = module.vpc.private_subnet1
  private_subnet2          = module.vpc.private_subnet2
  fargate_profile_name     = var.fargate_profile_name
  fargate_profile_role_arn = module.eks.fargate_profile_role_arn

}

module "argo_cd" {
  source                              = "../../aws_modules/argo"
  region                              = var.region
  cluster_name                        = var.cluster_name
  kubernetes_custom_resources_enabled = var.kubernetes_custom_resources_enabled
  root_app_repository_url             = var.root_app_repository_url
  root_app_repository_ref             = var.root_app_repository_ref
  depends_on = [
    module.eks
  ]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

  }
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}

## Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data)
  token                  = data.aws_eks_cluster_auth.example.token
}


output "endpoint" {
  value = module.eks.endpoint
}

output "certificate" {
  value = module.eks.kubeconfig-certificate-authority-data
}


