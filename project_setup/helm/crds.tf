data "kubectl_file_documents" "cert-manager-crd" {
  content = file(var.cm_file)
}

resource "kubectl_manifest" "cert-manager-crd-manifest" {
  for_each  = local.admin_chart.install ? data.kubectl_file_documents.cert-manager-crd.manifests : {}
  yaml_body = each.value
}

data "kubectl_file_documents" "traefik-crd" {
  content = file(var.traefik_file)
}

resource "kubectl_manifest" "traefik-crd-manifest" {
  for_each  = local.admin_chart.install ? data.kubectl_file_documents.traefik-crd.manifests : {}
  yaml_body = each.value
}