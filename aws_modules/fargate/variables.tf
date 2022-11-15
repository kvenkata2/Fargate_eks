variable "cluster_name" {
  default = "clus"
}

variable "fargate_profile_role_arn" {
  default = ""
}

variable "fargate_profile_name" {
  default = "kube-system"
}

variable "endpoint" {
  default = ""
}

variable "certificate" {
  default = ""
}

variable "private_subnet1" {
  default = ""
}

variable "private_subnet2" {
  default = ""
}