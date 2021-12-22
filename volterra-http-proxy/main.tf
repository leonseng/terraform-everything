provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_endpoint
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  resource_name = "http-proxy-${random_id.id.hex}"
}

data "volterra_namespace" "namespace" {
  name = var.namespace
}

resource "volterra_healthcheck" "healthcheck" {
  name                = local.resource_name
  namespace           = var.namespace
  healthy_threshold   = 2
  interval            = 10
  timeout             = 1
  unhealthy_threshold = 5

  http_health_check {
    host_header = var.lb_domain
    path        = "/"
  }
}

resource "volterra_origin_pool" "origin_pool" {
  name                   = local.resource_name
  namespace              = var.namespace
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = var.origin_server_port

  use_tls {
    no_mtls                = true
    use_host_header_as_sni = true
    volterra_trusted_ca    = true

    tls_config {
      default_security = true
    }
  }

  dynamic "origin_servers" {
    for_each = var.origin_server_public_ips
    content {
      public_ip {
        ip = origin_servers.value
      }
    }
  }

  healthcheck {
    name      = volterra_healthcheck.healthcheck.name
    namespace = volterra_healthcheck.healthcheck.namespace
    tenant    = data.volterra_namespace.namespace.tenant_name
  }
}

resource "volterra_http_loadbalancer" "http_lb" {
  name                            = local.resource_name
  namespace                       = var.namespace
  domains                         = [var.lb_domain]
  advertise_on_public_default_vip = true
  no_challenge                    = true
  round_robin                     = true
  multi_lb_app                    = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  user_id_client_ip               = true
  disable_waf                     = true

  https_auto_cert {
    http_redirect          = true
    no_mtls                = true
    disable_path_normalize = true
  }

  default_route_pools {
    pool {
      name      = volterra_origin_pool.origin_pool.name
      namespace = volterra_origin_pool.origin_pool.namespace
      tenant    = data.volterra_namespace.namespace.tenant_name
    }
    weight = 1
  }
}
