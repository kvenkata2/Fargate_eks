resource "null_resource" "name" {
  provisioner "local-exec" {
     command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}" 
  }
}
