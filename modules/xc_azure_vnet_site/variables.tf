variable "name" {
  description = "Module name"
  type        = string
}

variable "tenant" {
  description = "F5 XC tenant name"
  type        = string
}

variable "region" {
  description = "Region to deploy Azure resources in"
  type        = string
}

variable "resource_group" {
  description = "Resource group of VNet"
  type        = string
}

variable "ce_resource_group" {
  description = "Resource group to deploy CE in"
  type        = string
}

variable "az_cred" {
  description = "Azure cloud credential name"
  type        = string
}

variable "vnet_name" {
  description = "Name of VNet to deploy CE into"
  type        = string
}

variable "global_virtual_network" {
  description = "Global virtual network to connect site to"
  type        = string
}

variable "inside_subnet_name" {
  description = "Name of subnet to be connected to site local inside interface"
  type        = string
}

variable "outside_subnet_name" {
  description = "Subnet ID to be connected to site local outside interface"
  type        = string
}

variable "node_az" {
  description = "Availability zone to deploy XC node in"
  type        = number
}
