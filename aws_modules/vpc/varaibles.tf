variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = ["us-east-2a","us-east-2b"]
}

variable "cluster_name" {
  default = "clus"
}