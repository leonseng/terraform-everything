output "kubeconfig_file" {
  description = "Path to kubeconfig file for accessing the EKS cluster"
  value       = module.eks.kubeconfig_filename
}
