resource "azurerm_resource_group" "resource_group" {
  name     = "demo4terraform"
  location = "West Europe"
}

resource "azurerm_virtual_network" "virt_net" {
  name                = "Terraform-VN-VPN"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = var.vn_address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = "SubNet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virt_net.name
  address_prefix       = var.subnet_address_space
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virt_net.name
  address_prefix       = var.gw_subnet_address_space
}
