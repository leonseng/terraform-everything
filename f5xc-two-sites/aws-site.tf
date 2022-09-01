
# Deploy site A
module "aws_env" {
  source = "../modules/aws_env"

  name                  = "${random_id.id.dec}-aws"
  vpc_cidr              = "10.0.0.0/16"
  az                    = data.aws_availability_zones.local_az.names[0]
  public_subnet         = "10.0.1.0/24"
  private_subnet        = "10.0.11.0/24"
  ingress_allowed_cidrs = ["10.0.1.0/24", "10.50.11.0/24"]
  ssh_public_key        = var.ssh_public_key
}

resource "aws_subnet" "workload" {
  vpc_id            = module.aws_env.vpc_id
  availability_zone = data.aws_availability_zones.local_az.names[0]
  cidr_block        = "10.0.101.0/24"
  tags = {
    "Name" = "${random_id.id.dec}-workload-${data.aws_availability_zones.local_az.names[0]}"
  }
}

module "aws_vpc_site" {
  depends_on = [
    module.aws_env,
    volterra_cloud_credentials.aws_cc,
    volterra_k8s_cluster.k8s_cluster,
    volterra_virtual_network.global_network
  ]

  source = "../modules/xc_aws_vpc_site"

  name                   = "${random_id.id.dec}-aws"
  tenant                 = local.tenant_name
  namespace              = local.namespace_name
  vpc_id                 = module.aws_env.vpc_id
  aws_cred               = local.aws_cc_name
  aws_region             = var.aws_region
  node_az                = data.aws_availability_zones.local_az.names[0]
  outside_subnet_id      = module.aws_env.public_subnet_id
  inside_subnet_id       = module.aws_env.private_subnet_id
  workload_subnet_id     = aws_subnet.workload.id
  global_virtual_network = local.global_virtual_network_name
  k8s_cluster            = local.k8s_cluster_name
}

# Add route to site B via CE
data "aws_network_interface" "ce_sli" {
  depends_on = [
    module.aws_vpc_site
  ]

  filter {
    name   = "tag:ves-io-site-name"
    values = ["${random_id.id.dec}-aws"]
  }

  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-inside"]
  }
}

resource "aws_route" "to_remote_sli" {
  route_table_id         = module.aws_env.default_route_table_id
  destination_cidr_block = "10.50.11.0/24"
  network_interface_id   = data.aws_network_interface.ce_sli.id
}
