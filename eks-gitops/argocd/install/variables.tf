variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_id" {
  type = string
}

variable "argocd_install_manifest_url" {
  type    = string
  default = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}
