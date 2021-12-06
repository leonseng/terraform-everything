resource "kubernetes_namespace" "argocd" {
  depends_on = [
    module.vpc,
    module.eks,
  ]
  metadata {
    name = "argocd"
  }
}

# Install Argo CD in cluster
data "http" "argocd_install_manifest_url" {
  url = var.argocd_install_manifest_url
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_install_manifest_url.body
}

resource "kubectl_manifest" "argocd" {
  depends_on         = [kubernetes_namespace.argocd]
  wait               = true
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}

# Optionally create secret to store Github Personal Access Token for accessing repository containing Argo CD Application definitions
resource "kubernetes_secret" "gh_pat" {
  depends_on = [kubectl_manifest.argocd]
  count      = var.argocd_app_of_apps_repo_source.gh_personal_access_token == null ? 0 : 1
  metadata {
    name      = "argocd-repo-auth"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.argocd_app_of_apps_repo_source.repo_url
    username = var.argocd_app_of_apps_repo_source.gh_username
    password = var.argocd_app_of_apps_repo_source.gh_personal_access_token
  }
}

# Allow time for Argo Applications to be destroyed before destroying Argo CD installation.
# Without this, the CRDs may be deleted before the CRs are, leading to orphaned resources
# which prevents the argocd namespace from being cleaned up.
resource "time_sleep" "app_of_apps_cleanup" {
  depends_on       = [kubectl_manifest.argocd]
  destroy_duration = "60s"
}

# Deploy Argo CD applications using app of apps pattern
resource "kubectl_manifest" "argocd_app_of_apps" {
  depends_on = [time_sleep.app_of_apps_cleanup]
  wait       = true
  yaml_body = templatefile(
    "./templates/argocd_app_of_apps.tpl",
    {
      repo_url = var.argocd_app_of_apps_repo_source.repo_url
      path     = var.argocd_app_of_apps_repo_source.path
    }
  )
}
