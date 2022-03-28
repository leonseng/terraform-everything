output "kubeconfig_b64" {
  value     = base64encode(local.kubeconfig)
  sensitive = true
}
