resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = var.group_name
  virtual_network_name = var.virtual_network_name
  address_prefix       = "172.16.1.0/24"
}

resource "azurerm_public_ip" "app_gw_public_ip" {
  name                = "gateway-public-ip"
  resource_group_name = var.group_name
  location            = var.group_location
  allocation_method   = "Dynamic"
}

locals {
  backend_address_pool_name      = "Terraform-VN-VPN-beap"
  frontend_port_name             = "Terraform-VN-VPN-feport"
  frontend_ip_configuration_name = "Terraform-VN-VPN-feip"
  http_setting_name              = "Terraform-VN-VPN-be-htst"
  listener_name                  = "Terraform-VN-VPN-httplstn"
  request_routing_rule_name      = "Terraform-VN-VPN-rqrt"
  redirect_configuration_name    = "Terraform-VN-VPN-rdrcfg"
}

resource "azurerm_application_gateway" "app_gw" {
  name                = "test-app-gw"
  resource_group_name = var.group_name
  location            = var.group_location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-8761"
    port = 8761
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gw_public_ip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [var.vm_private_ip]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "euruka"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-8761"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

}
