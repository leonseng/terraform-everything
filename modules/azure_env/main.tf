resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.region
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "public" {
  name                 = "${var.name}-public"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet]
}

resource "azurerm_subnet" "private" {
  name                 = "${var.name}-private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet]
}

resource "azurerm_route_table" "private" {
  name                = "${var.name}-private"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.private.id
}

# NAT to enable outbound access for private subnet
resource "azurerm_public_ip" "nat_private" {
  name                = "${var.name}-nat-private"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "private" {
  name                = "${var.name}-private"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_nat_gateway_public_ip_association" "private" {
  nat_gateway_id       = azurerm_nat_gateway.private.id
  public_ip_address_id = azurerm_public_ip.nat_private.id
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  depends_on = [
    azurerm_subnet.private,
    azurerm_nat_gateway.private
  ]

  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.private.id
}

# VMs
resource "tls_private_key" "workload_access" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_interface" "workload" {
  name                = "${var.name}-workload"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = var.name
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "workload" {
  depends_on = [
    azurerm_subnet_nat_gateway_association.private
  ]

  name                = "${var.name}-workload"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_F2"
  admin_username      = var.workload_username
  network_interface_ids = [
    azurerm_network_interface.workload.id,
  ]

  admin_ssh_key {
    username   = var.workload_username
    public_key = tls_private_key.workload_access.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202207050"
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/files/user_data.sh.tpl",
      { user : var.workload_username, node_name : "${var.name}-azure" }
    )
  )
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.name}-bastion"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "bastion" {
  name                = "${var.name}-bastion"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "${var.name}-bastion"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "${var.name}-bastion"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_F2"
  admin_username      = var.workload_username
  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = var.workload_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202207050"
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/files/bastion.sh.tpl",
      { user : var.workload_username, host_private_key : tls_private_key.workload_access.private_key_pem }
    )
  )
}

data "azurerm_public_ip" "bastion" {
  depends_on = [
    azurerm_linux_virtual_machine.bastion
  ]

  name                = "${var.name}-bastion"
  resource_group_name = azurerm_resource_group.this.name
}
