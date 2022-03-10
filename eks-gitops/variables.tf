variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

# EKS
variable "k8s_version" {
  description = "Kubernetes cluster version"
  type        = string
  default     = "1.21"
}

variable "eks_worker_group" {
  description = "Cluster worker group configurations. See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/locals.tf"
  type = list(object({
    instance_type        = string
    asg_desired_capacity = number
    asg_max_size         = number
  }))
  default = [{
    asg_desired_capacity = 3
    asg_max_size         = 5
    instance_type        = "m4.large"
  }]
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
  default     = null
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
    path     = "eks-gitops/demo/argocd-apps"
    username = "nobody"
    password = null
  }
}

# kubeconfig AWS authenticator settings for SSO use case
variable "kubeconfig_aws_auth_env_variables" {
  description = "Environment variables that should be used when executing the authenticator"
  type        = map(string)
  default     = null
}
