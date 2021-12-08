output "kubeconfig_file" {
  value = abspath("${path.root}/${module.eks.kubeconfig_filename}")
}
