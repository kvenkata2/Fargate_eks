data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
# data "aws_caller_identity" "mgm_current" {
#   provider = aws.mgm
# }

locals {
  domain_name = "newcross-sbx.com"
}
data "aws_eks_cluster_auth" "example" {
  name = var.eks_name
}


data "aws_vpc" "vpc" {
  tags = {
    Name = var.eks_vpc_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    Type = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    Type = "public"
  }
}

data "aws_eks_cluster" "eks" {
  name = var.eks_name
}

data "aws_route53_zone" "newcross-sbx" {
  count    = local.admin_chart.use_local_zone == false ? 1 : 0
  #provider = aws.mgm
  name     = var.zone_name
}

# data "aws_route53_zone" "local" {
#   count = local.admin_chart.use_local_zone ? 1 : 0
#   provider = aws.mgm
#   name  = var.zone_name
# }

data "aws_iam_roles" "sso-admin-role" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_policy_document" "cloudwatch-mon-kms-policy" {

  statement {
    sid       = "KMSAdminAccess"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = data.aws_iam_roles.sso-admin-role.arns
    }
  }

  statement {
    sid       = "KMSRootAccess"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [local.aws_root_user_arn]
    }
  }

  statement {
    sid = "CloudWatchAccess"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      identifiers = ["logs.${var.region}.amazonaws.com"]
      type        = "Service"
    }
    condition {
      variable = "kms:EncryptionContext:aws:logs:arn"
      test     = "ArnEquals"
      values   = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }
}







# data "aws_lb" "admin-lb" {
#   depends_on = [helm_release.admin-stack]
#   tags = {
#     "elbv2.k8s.aws/cluster" = var.eks_name
#   }
# }