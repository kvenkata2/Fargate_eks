# resource "argocd_application" "helm" {
#   metadata {
#     name      = var.name
#     namespace = "argocd1"
#     labels = {
#       test = var.labels
#     }
#   }
#   wait = true
#   spec {
#     source {
#       repo_url        = var.repo_url
#       path = var.path
#       target_revision = var.target_revision
#       helm {
       
#         value_files = var.value_files
        
       
#       }
#     }

#     destination {
#       server    = var.server
#       namespace = var.dest_namespace
#     }
#     sync_policy {
#         automated ={
#             prune = var.prune
#             selfHeal = var.selfHeal
#         }
#     }
#   }
# }

resource "kubernetes_manifest" "root_app" {
  manifest = {
    apiVersion = var.apiVersion
    kind       = var.kind
    metadata = {
      name= var.name
      namespace = var.namespace
      finalizers = [
        "resources-finalizer.argocd.argoproj.io",
      ]
    }
    spec = {
      project = var.spec_project
      destination = {
        namespace = var.dest_namespace
        server    = var.server
      }
      source = {
        repoURL        = var.repo_url
        path           = var.path
        targetRevision = var.target_revision
        
      }
      syncPolicy = {
        automated = {
          prune    = var.prune
          selfHeal = var.selfHeal
        }
      }
    }
  }

  wait {
    fields = {
      "status.sync.status" = "Synced"
    }
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }

  field_manager {
    force_conflicts = true
  }
}
