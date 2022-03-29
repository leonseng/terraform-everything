resource "random_id" "id" {
  byte_length = 4
  prefix      = "tf-argocd-"
}

locals {
  kubeconfig      = yamldecode(var.kubeconfig_b64)
  kubeconfig_file = "${path.module}/.kube/${random_id.id.dec}.config"
}


resource "local_file" "kubeconfig" {
  content  = base64decode(var.kubeconfig_b64)
  filename = local.kubeconfig_file
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}

provider "kubectl" {
  config_path = local.kubeconfig_file
}
