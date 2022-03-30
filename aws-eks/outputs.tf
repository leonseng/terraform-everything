output "kubeconfig_file" {
  description = "Path to kubeconfig file for accessing the EKS cluster"
  value       = local.kubeconfig_file
}
