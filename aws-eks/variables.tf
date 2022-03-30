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
  type = object({
    min_size       = number
    desired_size   = number
    max_size       = number
    instance_types = list(string)
  })
  default = {
    min_size       = 3
    desired_size   = 3
    max_size       = 5
    instance_types = ["m4.large"]
  }
}

# Set this to '{ AWS_PROFILE : "<aws SSO profile defined in ~/.aws/config>" }' for SSO logins
variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator"
  type        = map(string)
  default     = {}
}
