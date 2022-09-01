provider "azurerm" {
  features {}
}

module "azure_env" {
  source = "../modules/azure_env"

  name                  = "${random_id.id.dec}-azure"
  region                = var.az_region
  vnet_cidr             = "10.50.0.0/16"
  public_subnet         = "10.50.1.0/24"
  private_subnet        = "10.50.11.0/24"
  ingress_allowed_cidrs = ["10.0.1.0/24", "10.50.11.0/24"]
  ssh_public_key        = var.ssh_public_key
}

module "azure_vnet_site" {
  depends_on = [
    module.azure_env,
    volterra_cloud_credentials.az_cc,
    volterra_virtual_network.global_network
  ]

  source = "../modules/xc_azure_vnet_site"

  name                   = "${random_id.id.dec}-azure"
  tenant                 = local.tenant_name
  region                 = var.az_region
  resource_group         = module.azure_env.resource_group
  ce_resource_group      = "${random_id.id.dec}-ce"
  az_cred                = local.az_cc_name
  vnet_name              = module.azure_env.vnet_name
  global_virtual_network = local.global_virtual_network_name
  inside_subnet_name     = module.azure_env.private_subnet_name
  outside_subnet_name    = module.azure_env.public_subnet_name
  node_az                = 1
}

# Add route to AWS site via CE
data "azurerm_network_interface" "ce-sli" {
  depends_on = [
    module.azure_vnet_site
  ]

  name                = "master-0-sli"
  resource_group_name = "${random_id.id.dec}-ce"
}

resource "azurerm_route" "to_remote_sli" {
  name                   = "toAwsInside"
  resource_group_name    = module.azure_env.resource_group
  route_table_name       = module.azure_env.private_route_table_name
  address_prefix         = "10.0.11.0/24"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.azurerm_network_interface.ce-sli.private_ip_address
}
