resource "volterra_aws_vpc_site" "aws_vpc_site" {
  name                    = var.name
  namespace               = "system"
  aws_region              = var.aws_region
  instance_type           = "t3.xlarge"
  logs_streaming_disabled = true
  no_worker_nodes         = true

  labels = {
    "deployment_id" = var.name
  }

  aws_cred {
    name      = var.aws_cred
    namespace = "system"
    tenant    = var.tenant
  }

  vpc {
    vpc_id = var.vpc_id
  }

  ingress_egress_gw {
    aws_certified_hw         = "aws-byol-multi-nic-voltmesh"
    no_dc_cluster_group      = true
    no_forward_proxy         = true
    no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    # inside_static_routes {
    #   static_route_list {
    #     simple_static_route = var.workload_subnet_cidr
    #   }
    # }

    allowed_vip_port {
      use_http_https_port = true
    }

    az_nodes {
      aws_az_name = var.node_az
      disk_size   = 0

      inside_subnet {
        existing_subnet_id = var.inside_subnet_id
      }

      outside_subnet {
        existing_subnet_id = var.outside_subnet_id
      }

      workload_subnet {
        existing_subnet_id = var.workload_subnet_id
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
  }

  # voltstack_cluster {
  #   aws_certified_hw = "aws-byol-voltstack-combo"
  #   az_nodes {
  #     aws_az_name = var.node_az
  #     disk_size   = 0

  #     local_subnet {
  #       existing_subnet_id = var.node_subnet_id
  #     }
  #   }
  #   no_network_policy        = true
  #   no_forward_proxy         = true
  #   no_outside_static_routes = true
  #   default_storage          = true

  #   global_network_list {
  #     global_network_connections {
  #       sli_to_global_dr {
  #         global_vn {
  #           name      = var.global_virtual_network
  #           namespace = "system"
  #           tenant    = var.tenant
  #         }
  #       }
  #     }
  #   }

  #   allowed_vip_port {
  #     use_http_https_port = true
  #   }

  #   k8s_cluster {
  #     tenant    = var.tenant
  #     namespace = "system"
  #     name      = var.k8s_cluster
  #   }
  # }

}

resource "volterra_tf_params_action" "aws_site_provisioner" {
  depends_on = [
    volterra_aws_vpc_site.aws_vpc_site
  ]
  site_name       = var.name
  site_kind       = "aws_vpc_site"
  action          = "apply"
  wait_for_action = true
}

data "aws_instance" "ce" {
  depends_on = [volterra_tf_params_action.aws_site_provisioner]

  instance_tags = {
    Name = "master-0"
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
