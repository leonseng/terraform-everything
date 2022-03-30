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

# Set this to '{ AWS_PROFILE : "<aws SSO profile defined in ~/.aws/config>" }' for SSO logins
variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator"
  type        = map(string)
}
