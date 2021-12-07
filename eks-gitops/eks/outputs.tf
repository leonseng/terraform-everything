output "cluster_id" {
  value = module.eks.cluster_id
}

output "kubeconfig_file" {
  value = module.eks.kubeconfig_filename
}
