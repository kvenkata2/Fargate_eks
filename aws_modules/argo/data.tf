# data "kubectl_file_documents" "namespace" {
#   content = file("${path.module}/manifests/argocd/namespace.yaml")
# }

# data "kubectl_file_documents" "argocd" {
#   content = file("${path.module}/manifests/argocd/install.yaml")
# }

# data "kubectl_file_documents" "my-nginx-app" {
#     content = file("${path.module}/manifests/argocd/my-nginx-app.yaml")
# }

# data "aws_eks_cluster_auth" "example" {
#   name = "terraform_cluster1"
# }

