resource "volterra_healthcheck" "f5_demo_httpd_hc" {
  depends_on = [
    volterra_namespace.namespace
  ]
  name                = "${random_id.id.dec}-f5-demo-httpd"
  namespace           = local.namespace_name
  healthy_threshold   = 3
  interval            = 3
  timeout             = 3
  unhealthy_threshold = 3
  jitter_percent      = 0

  http_health_check {
    use_origin_server_name = true
    path                   = "/txt"
    use_http2              = false
  }
}

resource "volterra_origin_pool" "f5_demo_httpd_op" {
  depends_on = [
    module.aws_site_provisioner_a,
    module.aws_site_provisioner_b,
    volterra_healthcheck.f5_demo_httpd_hc
  ]
  name                   = "${random_id.id.dec}-f5-demo-httpd"
  namespace              = local.namespace_name
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = 80
  no_tls                 = true
  same_as_endpoint_port  = true

  origin_servers {
    private_name {
      dns_name = aws_instance.server_a.private_dns
      site_locator {
        site {
          name      = "${local.aws_site_name}-a"
          namespace = "system"
          tenant    = local.tenant_name
        }
      }
      outside_network = true
    }
  }

  origin_servers {
    private_name {
      dns_name = aws_instance.server_b.private_dns
      site_locator {
        site {
          name      = "${local.aws_site_name}-b"
          namespace = "system"
          tenant    = local.tenant_name
        }
      }
      outside_network = true
    }
  }

  healthcheck {
    name      = "${random_id.id.dec}-f5-demo-httpd"
    namespace = local.namespace_name
    tenant    = local.tenant_name
  }
}

resource "volterra_http_loadbalancer" "f5_demo_httpd_lb" {
  depends_on = [
    volterra_origin_pool.f5_demo_httpd_op
  ]
  name      = "${random_id.id.dec}-f5-demo-httpd"
  namespace = local.namespace_name
  domains   = [local.service_fqdn]
  advertise_custom {
    advertise_where {
      site {
        network = "SITE_NETWORK_OUTSIDE"
        site {
          name      = "${local.aws_site_name}-a"
          namespace = "system"
          tenant    = local.tenant_name
        }
      }
      port = 80
    }
  }
  disable_waf         = true
  no_challenge        = true
  disable_rate_limit  = true
  round_robin         = true
  multi_lb_app        = true
  no_service_policies = true
  user_id_client_ip   = true

  default_route_pools {
    pool {
      tenant    = local.tenant_name
      namespace = local.namespace_name
      name      = "${random_id.id.dec}-f5-demo-httpd"
    }
    weight = 1
  }

  http {}
}
