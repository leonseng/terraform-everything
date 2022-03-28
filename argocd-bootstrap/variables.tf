variable "kubeconfig_b64" {
  description = "Base64 encoded string of the kubeconfig file contents to access the Kubernetes cluster"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace to deploy Argo CD in"
  type        = string
  default     = "argocd"
}

variable "argocd_install_manifest_url" {
  description = "URL to Argo CD manifests YAML file. See https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd"
  type        = string
  default     = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

variable "sealed_secrets_install_manifest_url" {
  description = "URL to Sealed Secrets manifests YAML file."
  type        = string
  default     = "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.17.3/controller.yaml"
}

variable "sealed_secret_key_manifest_b64" {
  description = "Base64 encoded manifest file containing backup of Sealed Secrets encryption keys. See https://github.com/bitnami-labs/sealed-secrets#how-can-i-do-a-backup-of-my-sealedsecrets."
  type        = string
  default     = ""
}

variable "bootstrap_app_source_repo" {
  description = "Repository containing Argo CD Application resources to be deployed in the cluster. GitHub private repositories can be accessed via Personal Access Tokens."
  type = object({
    url      = string
    revision = string
    path     = string
    username = string
    password = string
  })
  default = {
    url      = "https://github.com/leonseng/terraform-kubernetes-argocd-bootstrap.git"
    revision = "HEAD"
    path     = "test/demo/argocd-apps"
    username = "nobody"
    password = null
  }
}
