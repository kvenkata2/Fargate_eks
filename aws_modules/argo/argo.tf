# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.15.0"
    }
  }
}
resource "kubernetes_namespace_v1" "main" {
  metadata {
    name = var.kubernetes_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  depends_on = [
    null_resource.name
  ]
}


locals {
  private_repository = nonsensitive(var.git_credentials_url != "" && var.git_credentials_read_username != "" && var.git_credentials_read_token != "")
  admin_password     = coalesce(var.admin_password, try(one(random_password.admin_password[*].result)), "")
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "admin_password" {
  count = var.admin_password == "" ? 1 : 0

  length  = 16
  special = false
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "secret_key" {
  length  = 64
  special = true

  keepers = {
    # Generate a new secret key if the admin password changes
    admin_password = local.admin_password
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1
resource "kubernetes_secret_v1" "main" {
  metadata {
    name      = "argocd-secret"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  data = merge({
    "admin.password"      = bcrypt(local.admin_password, 10) # See https://github.com/argoproj/argo-helm/blob/66638628/charts/argo-cd/values.yaml
    "admin.passwordMtime" = timestamp()
    "server.secretkey"    = random_password.secret_key.result
  }, var.extra_secrets)

  lifecycle {
    ignore_changes = [
      data["admin.password"],
      data["admin.passwordMtime"],
    ]

    # replace_triggered_by = [
    #   # Recreate this Kubernetes secret if the admin password changes
    #   random_password.secret_key,
    # ]
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1
resource "kubernetes_secret_v1" "git_credentials" {
  count = local.private_repository ? 1 : 0

  metadata {
    name      = "argo-cd-git-credentials"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
      "app.kubernetes.io/managed-by"   = "Terraform"
    }
  }

  data = {
    type     = "git"
    url      = var.git_credentials_url
    username = var.git_credentials_read_username
    password = var.git_credentials_read_token
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1
resource "kubernetes_service_account_v1" "install" {
  metadata {
    name      = "argo-cd-install"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1
resource "kubernetes_cluster_role_v1" "install" {
  metadata {
    name = "${kubernetes_namespace_v1.main.metadata[0].name}:argo-cd-install"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1
resource "kubernetes_cluster_role_binding_v1" "install" {
  metadata {
    name = "${kubernetes_namespace_v1.main.metadata[0].name}:argo-cd-install"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.install.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.install.metadata[0].name
    namespace = kubernetes_service_account_v1.install.metadata[0].namespace
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resource
data "kubernetes_resource" "job_install" {
  api_version = "batch/v1"
  kind        = "Job"

  metadata {
    name      = kubernetes_job_v1.install.metadata[0].name
    namespace = kubernetes_job_v1.install.metadata[0].namespace
  }
}

# Instead of using the Terraform Helm provider, we use a job so we can fetch
# installation details from the argo-cd.application.yaml in the root app chart
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1
resource "kubernetes_job_v1" "install" {
  # depends_on = [
  #   kubernetes_cluster_role_v1.install,
  #   kubernetes_cluster_role_binding_v1.install,
  #   kubernetes_secret_v1.main,
  #   kubernetes_secret_v1.git_credentials,
  # ]

  wait_for_completion = true

  timeouts {
    create = "10m"
    update = "10m"
  }

  metadata {
    name      = "argo-cd-install"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  spec {
    backoff_limit = 0

    template {
      metadata {}

      spec {
        service_account_name = kubernetes_service_account_v1.install.metadata[0].name
        restart_policy       = "Never"

        container {
          name  = "install"
          image = "docker.io/library/alpine:3.16"
          command = [
            "ash",
            "-ce",
            <<-EOT
              # Install Helm
              ARCH=$(uname -m)
              case $ARCH in
                armv7*)  ARCH=arm;;
                aarch64) ARCH=arm64;;
                x86_64)  ARCH=amd64;;
                x86)     ARCH=386;;
                i686)    ARCH=386;;
                i386)    ARCH=386;;
                *) echo "Unsupported platform architecture: $ARCH" && exit 1;;
              esac
              case $ARCH in
                arm)   HELM_CHECKSUM=731637dd0df3ebae18b332b61edf755e14103ceb15817948a347b9d246d454ea;;
                arm64) HELM_CHECKSUM=2fcc6ffdaa280465f5a5c487ca87ad9bdca6101c714d3346ca6adc328e580b93;;
                amd64) HELM_CHECKSUM=111c4aa64532946feb11a1542e96af730f9748483ee56a06e6b67609ee8cfec3;;
                386)   HELM_CHECKSUM=d6c3efa2a26781a9f4d879e3370cdd60b24d93f58a51ce1bc2f225a7d287e4ea;;
              esac

              # Wait for the network
              until nslookup get.helm.sh;do
                sleep 5
              done

              wget -O /dev/stdout https://get.helm.sh/helm-v3.9.0-linux-$ARCH.tar.gz | tar -xz -C /usr/bin --strip-components=1 linux-$ARCH/helm
              sha256sum /usr/bin/helm
              echo "$HELM_CHECKSUM  /usr/bin/helm" | sha256sum -c

              apk add --no-cache git yq

              # Get and compile Argo CD application resource
              git clone $(echo "${var.root_app_repository_url}" | sed -E "s|(://)|\1$GIT_CREDENTIALS_USERNAME:$GIT_CREDENTIALS_PASSWORD@|") _root-app
              git -C _root-app checkout ${var.root_app_repository_ref}
              find _root-app/templates ! -name '*.tpl' ! -name 'argo-cd.application.yaml' -type f -delete
              helm template root-app ./_root-app \
                --set=namespace=${kubernetes_namespace_v1.main.metadata[0].name} \
                --debug \
                > app.yaml

              # Delete Argo CD before (re)installing
              helm delete --wait $(yq eval '.spec.source.helm.releaseName' app.yaml) || true

              # Install Argo CD using the Argo CD application resource
              eval $(echo helm upgrade --install $(yq eval '.spec.source.helm.releaseName' app.yaml) $(yq -e eval '.spec.source.chart' app.yaml) \
                --repo=$(yq -e eval '.spec.source.repoURL' app.yaml) \
                --namespace=$(yq -e eval '.spec.destination.namespace' app.yaml) \
                --create-namespace \
                --version=$(yq -e eval '.spec.source.targetRevision' app.yaml) \
                --reset-values \
                $(yq -e eval '.spec.source.helm.parameters[] | "--set=\"" + .name + "=" + .value + "\""' app.yaml | tr '\n' ' ') \
                --wait \
                --wait-for-jobs \
                --force)
            EOT
          ]

          env {
            name = "GIT_CREDENTIALS_USERNAME"
            value_from {
              secret_key_ref {
                name     = "argo-cd-git-credentials"
                key      = "username"
                optional = !local.private_repository
              }
            }
          }

          env {
            name = "GIT_CREDENTIALS_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "argo-cd-git-credentials"
                key      = "password"
                optional = !local.private_repository
              }
            }
          }
        }
      }
    }
  }
}
