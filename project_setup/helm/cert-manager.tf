data "aws_iam_policy_document" "cert-manager-assume-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [local.oidc_arn_for_cert_manager]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_without_https}:sub"
      values   = ["system:serviceaccount:${local.admin_chart.namespace}:${local.admin_chart.cert_manager_service_acccount}"]
    }
  }
}

data "aws_iam_policy_document" "cert-manager-route53-policy" {

  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/${local.hosted_zone_id}"]
  }
}





### same account roles
resource "aws_iam_role" "cert-manager-service-account-role-local" {
  count              = 1
  name               = "${var.eks_name}-cert-manager-service-account-role"
  assume_role_policy = data.aws_iam_policy_document.cert-manager-assume-role-policy.json

}

resource "aws_iam_policy" "cert-manager-route-53-policy-local" {
  count  = 1
  name   = "${var.eks_name}-cert-manager-service-account-policy"
  policy = data.aws_iam_policy_document.cert-manager-route53-policy.json

}

resource "aws_iam_role_policy_attachment" "cert-manager-route-53-policy-attachment-local" {
  count      = 1
  policy_arn = aws_iam_policy.cert-manager-route-53-policy-local[0].arn
  role       = aws_iam_role.cert-manager-service-account-role-local[0].id
}