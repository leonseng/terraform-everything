resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF
}

data "http" "argocd_install_manifest_url" {
  url = var.argocd_install_manifest
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_install_manifest.body
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.argocd_namespace,
  ]
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}
