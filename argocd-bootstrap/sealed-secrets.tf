resource "kubectl_manifest" "sealed_secrets_key" {
  count     = var.sealed_secret_key_manifest_b64 == "" ? 0 : 1
  wait      = true
  yaml_body = base64decode(var.sealed_secret_key_manifest_b64)
}

data "http" "sealed_secrets_install_manifest_url" {
  url = var.sealed_secrets_install_manifest_url
  request_headers = {
    Accept = "text/plain"
  }
}

data "kubectl_file_documents" "sealed_secrets" {
  content = data.http.sealed_secrets_install_manifest_url.body
}

# Install Sealed Secrets
resource "kubectl_manifest" "sealed_secrets" {
  depends_on = [
    kubectl_manifest.sealed_secrets_key
  ]
  wait      = true
  count     = length(data.kubectl_file_documents.sealed_secrets.documents)
  yaml_body = element(data.kubectl_file_documents.sealed_secrets.documents, count.index)
}
