output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "fargate_profile_role_arn" {
  value = aws_iam_role.eks-fargate-profile.arn
}