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

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_eks_cluster" "name" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.name.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.name.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
  load_config_file       = false
}

