variable "name" {
  description = "Module name"
  type        = string
}

variable "tenant" {
  description = "F5 XC tenant name"
  type        = string
}

variable "namespace" {
  description = "Namespace to create objects in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "aws_cred" {
  description = "AWS credential name"
  type        = string
}

variable "aws_region" {
  description = "Region to deploy AWS resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "node_az" {
  description = "Availability zone to deploy XC node in"
  type        = string
}

variable "inside_subnet_id" {
  description = "Subnet ID to be connected to XC node Inside interface"
  type        = string
}

variable "outside_subnet_id" {
  description = "Subnet ID to be connected to XC node Outside interface"
  type        = string
}

variable "workload_subnet_id" {
  description = "Subnet ID to be connected to deploy workload in"
  type        = string
}

variable "global_virtual_network" {
  description = "Global virtual network to connect site to"
  type        = string
}



variable "k8s_cluster" {
  description = "Kubenetes cluster"
  type        = string
}
