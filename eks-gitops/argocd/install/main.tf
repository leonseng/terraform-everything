provider "kubernetes" {
  config_path = var.kubeconfig_file
}

provider "kubectl" {
  load_config_file = true
  config_path      = var.kubeconfig_file
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

data "http" "argocd_install_manifest_url" {
  url = var.argocd_install_manifest_url
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_install_manifest_url.body
}

# Install Argo CD
resource "kubectl_manifest" "argocd" {
  depends_on         = [kubernetes_namespace.argocd]
  wait               = true
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}

# This ensures all Argo CD Application CRs are deleted before Argo CD installation is removed (along with the Application CRD).
# Without this, the Application CRs will be in a stuck state as Kubernetes can no longer query the CRs without the CRD.
resource "null_resource" "argocd_app_cleanup" {
  depends_on = [kubectl_manifest.argocd]
  triggers = {
    invokes_me_everytime = uuid()
    kubeconfig_file      = var.kubeconfig_file
  }

  provisioner "local-exec" {
    when    = destroy
    command = "until [ $(kubectl --kubeconfig ${self.triggers.kubeconfig_file} -n argocd get applications --no-headers 2>/dev/null | wc -l) -eq 0 ]; do sleep 3; done"
  }
}

# Optionally create a Secret for Argo CD to pull from private Git repositories
resource "kubernetes_secret" "private_repo_auth" {
  depends_on = [null_resource.argocd_app_cleanup]
  count      = var.bootstrap_app_source_repo.password == null ? 0 : 1
  metadata {
    name      = "private-repo-auth"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.bootstrap_app_source_repo.url
    username = var.bootstrap_app_source_repo.username
    password = var.bootstrap_app_source_repo.password
  }
}

# need to use kubectl_manifest here because kubernetes_manifest does not support defining CRD and CR in the same TF state
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "kubectl_manifest" "bootstrap_app" {
  depends_on = [null_resource.argocd_app_cleanup]
  wait       = true
  yaml_body = templatefile(
    "./bootstrap-app.yaml.tpl",
    {
      url  = var.bootstrap_app_source_repo.url
      path = var.bootstrap_app_source_repo.path
    }
  )
}
