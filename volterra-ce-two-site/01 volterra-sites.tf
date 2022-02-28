
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
  tenant_name    = data.volterra_namespace.namespace.tenant_name
  namespace_name = "${random_id.id.dec}-${var.namespace}"
  domain_suffix  = "${random_id.id.dec}.local"
  aws_cc_name    = "${random_id.id.dec}-cc"
  aws_site_name  = "${random_id.id.dec}-aws-site"
  service_fqdn   = "f5-demo.local"
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

resource "volterra_k8s_cluster" "k8s_cluster" {
  name                              = random_id.id.dec
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

resource "volterra_aws_vpc_site" "aws_vpc_site_a" {
  depends_on = [
    module.vpc_a,
    volterra_cloud_credentials.aws_cc,
    volterra_k8s_cluster.k8s_cluster
  ]

  name       = "${local.aws_site_name}-a"
  namespace  = "system"
  aws_region = var.region
  labels = {
    "deployment_id" = random_id.id.dec
  }

  aws_cred {
    name      = local.aws_cc_name
    namespace = "system"
    tenant    = local.tenant_name
  }

  instance_type           = "t3.xlarge"
  logs_streaming_disabled = true

  vpc {
    vpc_id = module.vpc_a.vpc_id
  }

  voltstack_cluster {
    aws_certified_hw = "aws-byol-voltstack-combo"
    az_nodes {
      aws_az_name = "${var.region}a"
      disk_size   = 0

      local_subnet {
        existing_subnet_id = module.vpc_a.public_subnets[0]
      }
    }
    no_network_policy        = true
    no_forward_proxy         = true
    no_outside_static_routes = true
    no_global_network        = true
    default_storage          = true

    allowed_vip_port {
      use_http_https_port = true
    }

    k8s_cluster {
      tenant    = local.tenant_name
      namespace = "system"
      name      = random_id.id.dec

    }
  }
  no_worker_nodes = true
}

module "aws_site_provisioner_a" {
  source  = "leonseng/volterra-cloud-site-provisioner/null"
  version = "1.0.1"

  api_endpoint = var.api_endpoint
  api_p12_file = var.api_p12_file
  site_id      = volterra_aws_vpc_site.aws_vpc_site_a.id
  site_name    = "${local.aws_site_name}-a"
  site_type    = "aws_vpc_site"
}

data "aws_instance" "node_a" {
  depends_on = [module.aws_site_provisioner_a]

  instance_tags = {
    Name = "master-0"
  }

  filter {
    name   = "vpc-id"
    values = [module.vpc_a.vpc_id]
  }
}

resource "volterra_aws_vpc_site" "aws_vpc_site_b" {
  depends_on = [
    module.vpc_b,
    volterra_cloud_credentials.aws_cc,
    volterra_k8s_cluster.k8s_cluster
  ]

  name       = "${local.aws_site_name}-b"
  namespace  = "system"
  aws_region = var.region
  labels = {
    "deployment_id" = random_id.id.dec
  }

  aws_cred {
    name      = local.aws_cc_name
    namespace = "system"
    tenant    = local.tenant_name
  }

  instance_type           = "t3.xlarge"
  logs_streaming_disabled = true

  vpc {
    vpc_id = module.vpc_b.vpc_id
  }

  voltstack_cluster {
    aws_certified_hw = "aws-byol-voltstack-combo"
    az_nodes {
      aws_az_name = "${var.region}a"
      disk_size   = 0

      local_subnet {
        existing_subnet_id = module.vpc_b.public_subnets[0]
      }
    }
    no_network_policy        = true
    no_forward_proxy         = true
    no_outside_static_routes = true
    no_global_network        = true
    default_storage          = true

    allowed_vip_port {
      use_http_https_port = true
    }

    k8s_cluster {
      tenant    = local.tenant_name
      namespace = "system"
      name      = random_id.id.dec

    }
  }
  no_worker_nodes = true
}

module "aws_site_provisioner_b" {
  source  = "leonseng/volterra-cloud-site-provisioner/null"
  version = "1.0.1"

  api_endpoint = var.api_endpoint
  api_p12_file = var.api_p12_file
  site_id      = volterra_aws_vpc_site.aws_vpc_site_b.id
  site_name    = "${local.aws_site_name}-b"
  site_type    = "aws_vpc_site"
}

data "aws_instance" "node_b" {
  depends_on = [module.aws_site_provisioner_b]

  instance_tags = {
    Name = "master-0"
  }

  filter {
    name   = "vpc-id"
    values = [module.vpc_b.vpc_id]
  }
}
