resource "kubectl_manifest" "argocd_namespace" {
  wait      = true
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF
}

# Install Argo CD in cluster
data "http" "argocd_install_manifest_url" {
  url = var.argocd_install_manifest_url
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_install_manifest_url.body
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.argocd_namespace,
  ]
  wait               = true
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}

# Optionally create secret to store Github Personal Access Token for accessing repository containing Argo CD Application definitions
resource "kubernetes_secret" "gh_pat" {
  count = var.argocd_app_of_apps_repo_source.gh_personal_access_token == null ? 0 : 1
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

# Deploy Argo CD applications using app of apps pattern
resource "kubectl_manifest" "argocd_app_of_apps" {
  depends_on = [
    kubectl_manifest.argocd_namespace,
  ]
  wait = true
  yaml_body = templatefile(
    "./templates/argocd_app_of_apps.tpl",
    {
      repo_url = var.argocd_app_of_apps_repo_source.repo_url
      path     = var.argocd_app_of_apps_repo_source.path
    }
  )
}
