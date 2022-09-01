output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "public_subnet_name" {
  value = azurerm_subnet.public.name
}

output "private_subnet_name" {
  value = azurerm_subnet.private.name
}

output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "bastion_public_ip" {
  value = data.azurerm_public_ip.bastion.ip_address
}

output "workload_private_ip" {
  value = azurerm_network_interface.workload.private_ip_address
}

output "private_route_table_name" {
  value = azurerm_route_table.private.name
}
