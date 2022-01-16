provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_endpoint
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  resource_name = "${var.resource_prefix}-${random_id.id.hex}"
}

data "volterra_namespace" "namespace" {
  name = var.namespace
}

resource "volterra_cloud_credentials" "aws_cc" {
  name      = "${local.resource_name}-cc"
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

resource "volterra_aws_vpc_site" "aws_vpc_site" {
  name       = "${local.resource_name}-aws"
  namespace  = "system"
  aws_region = var.region

  aws_cred {
    name      = "${local.resource_name}-cc"
    namespace = "system"
    tenant    = data.volterra_namespace.namespace.tenant_name
  }

  instance_type           = var.instance_type
  logs_streaming_disabled = true

  vpc {
    new_vpc {
      name_tag      = "${local.resource_name}-vpc"
      primary_ipv4  = "10.0.0.0/16"
      allocate_ipv6 = false
    }
  }

  ingress_gw {
    aws_certified_hw = "aws-byol-voltmesh"
    az_nodes {
      aws_az_name = "${var.region}a"
      disk_size   = 0

      local_subnet {
        subnet_param {
          ipv4 = "10.0.1.0/24"
        }
      }
    }
    allowed_vip_port {
      use_http_https_port = true
    }
  }
  no_worker_nodes = true
  depends_on = [
    volterra_cloud_credentials.aws_cc
  ]
}

resource "null_resource" "terraform_action" {
  triggers = {
    api_p12_file      = var.api_p12_file
    api_endpoint      = var.api_endpoint
    aws_vpc_site_name = "${local.resource_name}-aws"
  }

  provisioner "local-exec" {
    # apply terraform and check status till status = applied?
    command     = "./files/apply.sh ${self.triggers.api_p12_file} ${self.triggers.api_endpoint} ${self.triggers.aws_vpc_site_name}"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "./files/destroy.sh ${self.triggers.api_p12_file} ${self.triggers.api_endpoint} ${self.triggers.aws_vpc_site_name}"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    volterra_aws_vpc_site.aws_vpc_site
  ]
}
