locals {
  oidc_url_without_https    = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  oidc_cert_manager_account =  data.aws_caller_identity.current.account_id 
  oidc_arn_for_cert_manager = "arn:aws:iam::${local.oidc_cert_manager_account}:oidc-provider/${local.oidc_url_without_https}"
  oidc_arn_for_lb           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url_without_https}"
  oidc_arn_for_fb           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url_without_https}"

  hosted_zone_id = var.zone_id

  region_short      = join("", [for s in split("-", var.region) : substr(s, 0, 1)])
  aws_root_user_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
 
  admin_chart = {
    install                           = lookup(var.admin_chart, "install", true)
    namespace                         = lookup(var.admin_chart, "namespace", "admin")
    cert_manager_service_acccount     = lookup(var.admin_chart, "cert_manager_service_acccount", "cert-manager-service-account")
    aws_lb_controller_service_account = lookup(var.admin_chart, "aws_lb_controller_service_account", "aws-lb-controller-service-account")
    cluster_issuer_email              = lookup(var.admin_chart, "cluster_issuer_email", "devops@gomedigo.io")
    traefik_replicas                  = lookup(var.admin_chart, "traefik_replicas", 1)
    use_local_zone                    = lookup(var.admin_chart, "use_local_zone", false)
    route53_alias_records_to_add      = lookup(var.admin_chart, "route53_alias_records_to_add", [])
  }
 

  # tags = {
  #   Git_Commit_Id      = var.git_commit_id
  #   Created_By         = var.created_by
  #   Creation_Source    = "Terraform"
  #   Gitlab_Project_Url = var.github_project_url
  # }

  current_data = formatdate("YYYYMMDDhhmm", timestamp())
}