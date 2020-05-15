resource "azurerm_public_ip" "public_ip" {
  name                = "PublicIPforGCP"
  resource_group_name = var.group_name
  location            = var.group_location

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vnet_gateway" {
  name                = "VirtualnetGW-VPN-Terraform"
  resource_group_name = var.group_name
  location            = var.group_location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}

resource "azurerm_local_network_gateway" "local_network_gw" {
  name                = "LocalNetworkGW"
  resource_group_name = var.group_name
  location            = var.group_location
  gateway_address     = var.gcp_public_ip
  address_space       = var.address_space_local_nw_gw
}

resource "azurerm_virtual_network_gateway_connection" "az_gcp_vpn_connction" {
  name                = "az_gcp_vpn_connction"
  resource_group_name = var.group_name
  location            = var.group_location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gw.id

  shared_key = var.shared_secret_key
}
