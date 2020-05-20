resource "azurerm_virtual_machine_scale_set" "vm_scale_set" {
  name                = "test-scale-set"
  location            = var.group_location
  resource_group_name = var.group_name

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Automatic"

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 1
  }

  storage_profile_image_reference {
    id = var.image_id
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name_prefix = "scale-vm"
    admin_username       = "teamcity"
    admin_password       = "Owl123456789"
  }

  os_profile_linux_config {
    ssh_keys {
      path     = "/home/teamcity/.ssh/authorized_keys"
      key_data = file("/root/.ssh/.tc/id_rsa.pub")
    }
  }

  network_profile {
    name    = "autoscale-nw-profile"
    primary = true

    ip_configuration {
      name                                         = "as-ip-configuration"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = [var.as_backends_add_pool]
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscaling" {
  name                = "Autoscaling"
  resource_group_name = var.group_name
  location            = var.group_location
  target_resource_id  = azurerm_virtual_machine_scale_set.vm_scale_set.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vm_scale_set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 20
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT3M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vm_scale_set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 5
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT3M"
      }
    }
  }
}
