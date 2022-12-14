aws_access_key                      = ""
aws_secret_key                      = ""
region                              = "us-east-1"
cluster_name                       = "terraform_cluster"
vpc_cidr                            = "10.0.0.0/16"
availability_zone                   = ["us-east-2a", "us-east-2b"]
fargate_profile_name                = "kube-system"
kubernetes_custom_resources_enabled = true
root_app_crd_api_version            = "argoproj.io/v1alpha1"
root_app_repository_url             = "https://github.com/Akshayhvg1008/kk"
root_app_repository_ref             = "HEAD"