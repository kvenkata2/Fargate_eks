module "helm" {
  source       = "../helm"
  traefik_file = "../helm/crds/traefik.yaml"
  cm_file      = "../helm/crds/cert-manager.yaml"
}
