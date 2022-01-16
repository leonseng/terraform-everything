provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_endpoint
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.resource_prefix}-"
}

data "volterra_namespace" "namespace" {
  name = var.namespace
}

locals {
  tenant_name = data.volterra_namespace.namespace.tenant_name
}

resource "volterra_cloud_credentials" "aws_cc" {
  name      = "${random_id.id.dec}-cc"
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

module "edge_site_1" {
  source                     = "../../"
  api_endpoint               = var.api_endpoint
  api_p12_file               = var.api_p12_file
  resource_prefix            = "${random_id.id.dec}-edge-1"
  tenant_name                = local.tenant_name
  aws_cloud_credentials_name = "${random_id.id.dec}-cc"
  region                     = var.region
  instance_type              = var.instance_type
  labels = {
    "test_label" = "Hello"
  }

  depends_on = [
    volterra_cloud_credentials.aws_cc
  ]
}
