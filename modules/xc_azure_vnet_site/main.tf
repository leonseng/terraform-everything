resource "volterra_azure_vnet_site" "this" {
  name                     = var.name
  namespace                = "system"
  resource_group           = var.ce_resource_group
  azure_region             = var.region
  no_worker_nodes          = true
  logs_streaming_disabled  = true
  default_blocked_services = true
  machine_type             = "Standard_D3_v2"

  azure_cred {
    name      = var.az_cred
    namespace = "system"
    tenant    = var.tenant
  }

  vnet {
    existing_vnet {
      resource_group = var.resource_group
      vnet_name      = var.vnet_name
    }
  }

  ingress_egress_gw {
    no_network_policy        = true
    no_forward_proxy         = true
    azure_certified_hw       = "azure-byol-multi-nic-voltmesh"
    no_inside_static_routes  = true
    no_outside_static_routes = true
    no_global_network        = true
    no_dc_cluster_group      = true
    # sm_connection_public_ip  = true

    az_nodes {
      azure_az = var.node_az

      inside_subnet {
        subnet {
          subnet_name         = var.inside_subnet_name
          vnet_resource_group = true
        }
      }

      outside_subnet {
        subnet {
          subnet_name         = var.outside_subnet_name
          vnet_resource_group = true
        }
      }
    }

    global_network_list {
      global_network_connections {
        sli_to_global_dr {
          global_vn {
            name      = var.global_virtual_network
            namespace = "system"
            tenant    = var.tenant
          }
        }
      }
    }

    local_control_plane {
      no_local_control_plane = true
    }
  }
}

resource "volterra_tf_params_action" "this" {
  depends_on = [
    volterra_azure_vnet_site.this
  ]

  site_name       = var.name
  site_kind       = "azure_vnet_site"
  action          = "apply"
  wait_for_action = true
}
