output "as_backends_add_pool" {
  value = azurerm_application_gateway.app_gw.backend_address_pool.1.id
}

output "probe_id" {
  value = azurerm_application_gateway.app_gw.probe.id
}
