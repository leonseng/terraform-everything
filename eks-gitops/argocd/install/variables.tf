variable "kubeconfig_file" {
  type = string
}

variable "argocd_install_manifest_url" {
  type    = string
  default = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

variable "bootstrap_app_source_repo" {
  description = "Repository containing Argo CD Application resources to be deployed in the cluster. GitHub private repositories can be accessed via Personal Access Tokens."
  type = object({
    url      = string
    path     = string
    username = string
    password = string
  })
  default = {
    url      = "https://github.com/leonseng/terraform-everything.git"
    path     = "eks-gitops/argocd/demo/argocd-apps"
    username = "nobody"
    password = null
  }
}
