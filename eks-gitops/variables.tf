variable "region" {
  type        = string
  description = "Region to deploy resources in"
  default     = "ap-southeast-2"
}

# EKS
variable "k8s_version" {
  type        = string
  description = "Kubernetes cluster version"
  default     = "1.21"
}

variable "eks_worker_group" {
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

# Argo CD
variable "argocd_install_manifest_url" {
  type    = string
  default = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}
