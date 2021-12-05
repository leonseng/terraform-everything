resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF
}

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
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}

data "template_file" "argocd_app_of_apps_manifest" {
  template = file("./templates/argocd_app_of_apps.tpl")
  vars = {
    repo_url = var.argocd_app_of_apps_repo_source.repo_url
    path     = var.argocd_app_of_apps_repo_source.path
  }
}

resource "kubectl_manifest" "argocd_app_of_apps" {
  depends_on = [
    kubectl_manifest.argocd,
  ]
  yaml_body = data.template_file.argocd_app_of_apps_manifest.rendered
}
