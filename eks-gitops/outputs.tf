output "kubeconfig_file" {
  value = abspath("${path.root}/${module.eks.kubeconfig_filename}")
}

output "argocd_server_url" {
  value = "https://${data.kubernetes_service.argocd_server_lb.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_server_admin_password" {
  value     = data.kubernetes_secret.argocd_server_password.data.password
  sensitive = true
}
