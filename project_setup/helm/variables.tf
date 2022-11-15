variable "server_addr" {
  default = ""
}

variable "argo_username" {
  default = "admin"
}

variable "argo_password" {
  default = "kvg"
}


variable "eks_name" {
  type = string
  default = "terraform_cluster1"
}

variable "eks_vpc_name" {
  type = string
  default = "vpc"
}

variable "eks_endpoint" {
  type = string
  default = "https://3B4FF6EE822EDFF441663604D8F2DE35.gr7.us-east-2.eks.amazonaws.com"
}

variable "eks_certificate" {
  type = string
  default = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1URXdNakUxTlRrd01sb1hEVE15TVRBek1ERTFOVGt3TWxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTnVmCkUzNkJjOEMvblZsem11bXlkMk9zWGtvT0VJWjVoc09OclU2NXJtTWVHOE9wSGw0VEUwZ0hrNmJRSkRrUGt1VGwKYkRINXM2MWJ6V3ppOVZ4S0hvWkxXcVIwTk1INkFzK3kyVU9xWTVNeUYrV0NVZE5JVDVHR1VRRDd1cnZpa2NSTwoxaHJ5Z25MVkxsak9KdC80RmMweG1XRmxzbldIbW41VU5qM2s0YktuemZQckVxZjN3NmFZMFpPU3BNdWZwenJECmhJMUxNbHNYdXVJN2lJS3ZZSVN1b1lwSTBWckFwYXUxVWRzOU9FZ1lNVTRKL0hxRGlFaUk4L09sR2twUUpBT24KWDQxOFlXUFF0NU94bndyVGhaOEVIZVpDOEZ2MG1PdEtJdFdLWU5zRDVoQ2M0a1dLNkc3S0tuVDh1TEpSMFpIWQp4YXAvZU9mMDhLMGQzVzdySzRNQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZGMUVCMXBLakZxN2pPTURhVXYrcjhUMDEwazdNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSHN1RFozNEk5MTh5QUg1SzR1MQpLSnNRNDNlVzM5WVZqZXlwQ2Q4ZldncDFVWHlhUUwwa1V1MkNqcEliYnlhNlFVa0NXZi96cU9YVGJSZ0J2Vk1kCm9lZ1crMk9sZ3pqUllJSzM0TU9YL0gwY1ZVaGxxV3dlbGF5azBrM0pVU2lJcjFIek9ML0Q5NjlHMy9GUitPVVgKV3ZvbkZ0MGx2eDhuK1FnS3A3ancya24wVzNod1hIV3VZUVUrVklhOGtNZUJ1M0RiK3NZQUhuRjNRR1N1S1RJeQpvK3lyQVVvUXBkNWl4d0VVZ1RyaEhOMHBCR2txeG1VenErVzRnY1dTTmNURzlDcmFaTVN5UmVrNlRWbFhFMUdJCjIvR3dhcGdRcmhFRHZxT29ONXJjQzZlYlczcnRxVVM0ejVnWHc3bTZjYWw2dmlMMzdkR1lxMnZveXkzcXNCTDIKdTMwPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
}



variable "env_name" {
  type    = string
  default = "dev"
}

# variable "git_commit_id" {
#   type = string
# }

# variable "created_by" {
#   type = string
# }

# variable "github_project_url" {
#   type = string
# }

variable "admin_chart" {
  type    = any
  default = {}
}

variable "create_env_fargate_profile" {
  type    = bool
  default = true
}

variable "create_env_namespace" {
  type    = bool
  default = true
}

variable "assume_role_arn" {
  type    = string
  default = "arn:aws:iam::128230169866:role/np-assume-role"
}

variable "mgm_assume_role_arn" {
  type    = string
  default = null
}

variable "secondary_region" {
  type    = string
  default = "eu-west-1"
}

variable "zone_name" {
  type    = string
  default = "newcross-sbx.com."
}
variable "zone_id" {
  type    = string
  default = "Z03885103HYJ4B975P0AR"
}

variable "enable_aws_fargate_logging" {
  type    = bool
  default = false
}

variable "image_upload_s3_bucket_name" {
  type    = string
  default = null
}

variable "image_upload_s3_kms_alias" {
  type    = string
  default = null
}

## aws distro for open telemetry
variable "enable_adot" {
  type    = bool
  default = false
}
variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

variable "region" {
  default = "us-east-2"
}

variable "name" {
  default = "nginx"
}

variable "namespace" {
  default = "argocd"
}

variable "labels" {
  default = "true"
}

variable "wait" {
   type   = bool 
  default = true
}
##source##
variable "repo_url" {
  default = "https://github.com/AnaisUrlichs/terraform-helm-example"
}

variable "path" {
  default = "charts/nginx"
}

variable "target_revision" {
  default = "HEAD"
}

variable "value_files" {
  default = ["values.yaml"]
}

variable "apiVersion" {
  default = "argoproj.io/v1alpha1"
}
variable "kind" {
  default = "Application"
}
##destination##
variable "server" {
  default = "https://kubernetes.default.svc"
}

variable "dest_namespace" {
  default = "default"
}
##sync policy##

variable "prune" {
  type    = bool
  default = "false"
}

variable "selfHeal" {
  type    = bool
  default = "false"
}

variable "spec_project" {
  default = "default"
}



variable "traefik_file" {
  # default = ""
}

variable "cm_file" {
  
}