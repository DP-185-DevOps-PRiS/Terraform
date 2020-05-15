output "group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "group_location" {
  value = azurerm_resource_group.resource_group.location
}

output "gateway_subnet_id" {
  value = azurerm_subnet.gateway_subnet.id
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.virt_net.name
}
