provider "kubernetes" {
  config_path = var.kubeconfig_file
}

provider "kubectl" {
  config_path = var.kubeconfig_file
}
