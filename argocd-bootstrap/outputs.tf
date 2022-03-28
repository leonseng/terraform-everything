output "argocd_server_url" {
  description = "URL to access Argo CD server web UI"
  value       = "https://${data.kubernetes_service.argocd_server_lb.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_server_admin_password" {
  description = "Admin password for accessing Argo CD server web UI"
  value       = data.kubernetes_secret.argocd_server_password.data.password
  sensitive   = true
}
