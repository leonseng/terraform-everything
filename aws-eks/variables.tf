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

variable "eks_managed_node_group_configuration" {
  description = "Cluster worker group configurations."
  type = list(object({
    instance_type = string
    desired_size  = number
    max_size      = number
  }))
  default = [{
    desired_size  = 3
    max_size      = 5
    instance_type = "m4.large"
  }]
}
