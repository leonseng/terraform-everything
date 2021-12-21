provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_endpoint
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  resource_name = "tcp-proxy-${random_id.id.hex}"
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

  tcp_health_check {}
}

resource "volterra_origin_pool" "origin_pool" {
  name                   = local.resource_name
  namespace              = var.namespace
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  healthcheck {
    name      = local.resource_name
    namespace = var.namespace
    tenant    = data.volterra_namespace.namespace.tenant_name
  }

  dynamic "origin_servers" {
    for_each = var.origin_server_public_ips
    content {
      public_ip {
        ip = origin_servers.value
      }
    }
  }

  port   = var.origin_server_port
  no_tls = true
}

resource "volterra_tcp_loadbalancer" "tcp_lb" {
  name                            = local.resource_name
  namespace                       = var.namespace
  domains                         = [var.lb_domain]
  listen_port                     = var.origin_server_port
  with_sni                        = true
  advertise_on_public_default_vip = true
  retract_cluster                 = true
  hash_policy_choice_round_robin  = true
  idle_timeout                    = var.lb_idle_timeout
  origin_pools_weights {
    pool {
      name      = local.resource_name
      namespace = var.namespace
      tenant    = data.volterra_namespace.namespace.tenant_name
    }
  }
}
