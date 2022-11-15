resource "aws_eks_fargate_profile" "kube-system" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.fargate_profile_name
  pod_execution_role_arn = var.fargate_profile_role_arn

  # These subnets must have the following resource tag: 
  # kubernetes.io/cluster/<CLUSTER_NAME>.
  subnet_ids = [
    var.private_subnet1,
    var.private_subnet2
  ]

  selector {
    namespace = "kube-system"
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

resource "null_resource" "k8s_patcher" {
  depends_on = [aws_eks_fargate_profile.kube-system]

  triggers = {
    endpoint = var.endpoint
    ca_crt   = base64decode(var.certificate)
    token    = data.aws_eks_cluster_auth.eks.token
  }

  provisioner "local-exec" {
    command = <<EOH
    cat >/tmp/ca.crt <<EOF
    ${base64decode(var.certificate)}
    EOF
    kubectl \
    --server="${var.endpoint}" \
    --certificate_authority=/tmp/ca.crt \
    --token="${data.aws_eks_cluster_auth.eks.token}" \
    patch deployment coredns \
    -n kube-system --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
    EOH
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}
