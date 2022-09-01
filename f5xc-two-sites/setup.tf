terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "~> 0.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_endpoint
}

resource "random_id" "id" {
  byte_length = 2
  prefix      = "${var.namespace}-"
}

data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
}

resource "volterra_namespace" "namespace" {
  name = "${random_id.id.dec}-${var.namespace}"
}

data "volterra_namespace" "namespace" {
  depends_on = [
    volterra_namespace.namespace
  ]
  name = "${random_id.id.dec}-${var.namespace}"
}

locals {
  tenant_name                 = data.volterra_namespace.namespace.tenant_name
  namespace_name              = "${random_id.id.dec}-${var.namespace}"
  domain_suffix               = "${random_id.id.dec}.local"
  service_fqdn                = "f5-demo.local"
  aws_cc_name                 = "${random_id.id.dec}-cc"
  az_cc_name                  = "${random_id.id.dec}-az"
  k8s_cluster_name            = "${random_id.id.dec}-k8s"
  global_virtual_network_name = "${random_id.id.dec}-gvn"
}

resource "volterra_k8s_cluster" "k8s_cluster" {
  name                              = local.k8s_cluster_name
  namespace                         = "system"
  no_cluster_wide_apps              = true
  use_default_cluster_role_bindings = true
  use_default_cluster_roles         = true
  cluster_scoped_access_deny        = true
  global_access_enable              = true
  no_local_access                   = true
  no_insecure_registries            = true
  use_default_psp                   = true
}

resource "volterra_virtual_network" "global_network" {
  name      = local.global_virtual_network_name
  namespace = "system"

  global_network = true
}

resource "volterra_cloud_credentials" "aws_cc" {
  name      = local.aws_cc_name
  namespace = "system"

  aws_secret_key {
    access_key = var.aws_access_key
    secret_key {
      clear_secret_info {
        url = "string:///${base64encode(var.aws_secret_key)}"
      }
    }
  }
}

resource "volterra_cloud_credentials" "az_cc" {
  name      = local.az_cc_name
  namespace = "system"

  azure_client_secret {
    client_id       = var.az_sp_app_id
    subscription_id = var.az_sp_subscription_id
    tenant_id       = var.az_sp_tenant_id
    client_secret {
      clear_secret_info {
        url = "string:///${base64encode(var.az_sp_password)}"
      }
    }
  }
}
