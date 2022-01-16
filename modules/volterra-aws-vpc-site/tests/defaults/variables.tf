variable "api_endpoint" {
  description = "Tenant API url"
  type        = string
}

variable "api_p12_file" {
  description = "API credential p12 file path"
  type        = string
}

variable "resource_prefix" {
  description = "String prefixed to all Volterra resource names"
  type        = string
  default     = "aws-vpc-site-test"
}

variable "namespace" {
  description = "Namespace to create objects in"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key for deploying Voltstack site"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key for deploying Voltstack site"
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
