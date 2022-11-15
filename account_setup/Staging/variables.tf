variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

variable "region" {
  default = "us-east-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "cluster_name" {
  default = "terraform_cluster1"
}

variable "fargate_profile_name" {
  default = "kube-system"
}

variable "availability_zone" {
  default = ["us-east-2a","us-east-2b"]
}



variable "kubernetes_custom_resources_enabled" {
  description = "Disable Kubernetes custom resources to prevent failing an initial plan when Kubernetes and/or its Custom Resource Definitions are not yet available"
  type        = bool
  default     = true
}

variable "kubernetes_namespace" {
  description = "The Kubernetes namespace Argo CD resources are deployed to"
  type        = string
  default     = "argocd"
}

variable "admin_password" {
  description = "A new Argo CD admin password"
  sensitive   = true
  type        = string
  default     = ""
}

variable "extra_secrets" {
  description = "A map of key-value pairs to store in the 'argocd-secret' Kubernetes secret"
  sensitive   = true
  type        = map(string)
  default     = {}
}

variable "git_credentials_url" {
  description = "The URL the git credentails the credentials are scoped to"
  type        = string
  default     = ""
}

variable "git_credentials_read_username" {
  description = "A username to access the git repository (read-only recommended)"
  type        = string
  default     = ""
}

variable "git_credentials_read_token" {
  description = "A token/password to access the git repository (read-only recommended)"
  sensitive   = true
  type        = string
  default     = ""
}

variable "root_app_crd_api_version" {
  description = "The Kubernetes ApiVersion of the Argo CD root app custom resource"
  type        = string
  default     = "argoproj.io/v1alpha1"
}

variable "root_app_repository_url" {
  description = "The git repository URL where your root app (app of apps) is hosted (fork from https://gitlab.com/vlasman/root-app-chart)"
  type        = string
  default = ""
}

variable "root_app_repository_ref" {
  description = "The git repository reference (branch/tag/HEAD) of your root app (app of apps)"
  type        = string
  default     = "HEAD"
}

variable "root_app_chart_parameters" {
  description = "Extra Helm chart parameters to pass to your root app (app of apps)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "root_app_chart_values" {
  description = "Extra Helm chart values to pass to your root app (app of apps)"
  type        = string
  default     = ""
}

