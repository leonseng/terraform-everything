variable "api_endpoint" {
  description = "Tenant API url"
  type        = string
}

variable "api_p12_file" {
  description = "API credential p12 file path"
  type        = string
}

variable "name" {
  description = "Module instance name"
  type        = string
  default     = "aws_vpc_site"
}

/* Can be obtained using
    data "volterra_namespace" "namespace" {
      name = var.namespace
    }

    data.volterra_namespace.namespace.tenant_name
*/
variable "tenant_name" {
  description = "Volterra tenant name"
  type        = string
}

variable "aws_cloud_credentials_name" {
  description = "Name of AWS cloud credentials object stored in the same Volterra tenancy"
  type        = string
}

variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "Voltstack EC2 node instance type"
  type        = string
  default     = "t3.xlarge"
}

variable "labels" {
  description = "Volterra labels to be applied on the AWS VPC site"
  type        = map(string)
}

variable "tf_apply_timeout_minutes" {
  description = "Time to wait (in minutes) for terraform to successfully create AWS VPC site"
  type        = number
  default     = 20
}

variable "tf_destroy_timeout_minutes" {
  description = "Time to wait (in minutes) for terraform to successfully destroy AWS VPC site"
  type        = number
  default     = 20
}
