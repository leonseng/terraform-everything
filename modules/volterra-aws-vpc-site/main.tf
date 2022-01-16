resource "volterra_aws_vpc_site" "aws_vpc_site" {
  name       = var.name
  namespace  = "system"
  aws_region = var.region
  labels     = var.labels

  aws_cred {
    name      = var.aws_cloud_credentials_name
    namespace = "system"
    tenant    = var.tenant_name
  }

  instance_type           = var.instance_type
  logs_streaming_disabled = true

  vpc {
    new_vpc {
      name_tag      = var.name
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
}

resource "null_resource" "terraform_action" {
  triggers = {
    api_p12_file      = var.api_p12_file
    api_endpoint      = var.api_endpoint
    aws_vpc_site_name = var.name
    timeout           = var.tf_apply_timeout_minutes
  }

  provisioner "local-exec" {
    # apply terraform and check status till status = applied
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
${path.module}/files/apply.sh \
  ${self.triggers.api_p12_file} \
  ${self.triggers.api_endpoint} \
  ${self.triggers.aws_vpc_site_name} \
  ${self.triggers.timeout}
EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
${path.module}/files/destroy.sh \
  ${self.triggers.api_p12_file} \
  ${self.triggers.api_endpoint} \
  ${self.triggers.aws_vpc_site_name} \
  ${self.triggers.timeout}
EOT
  }

  depends_on = [
    volterra_aws_vpc_site.aws_vpc_site
  ]
}
