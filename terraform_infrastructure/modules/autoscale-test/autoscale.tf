resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-public-ip"
  resource_group_name = var.group_name
  location            = var.group_location
  allocation_method   = "Static"
}

resource "azurerm_lb" "autoscale_lb" {
  name                = "autoscale-lb"
  location            = var.group_location
  resource_group_name = var.group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_be_add_pool" {
  resource_group_name = var.group_name
  loadbalancer_id     = azurerm_lb.autoscale_lb.id
  name                = "LBBackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lb_nat_pool" {
  resource_group_name            = var.group_name
  name                           = "main-traffic"
  loadbalancer_id                = azurerm_lb.autoscale_lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 90
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = var.group_name
  loadbalancer_id     = azurerm_lb.autoscale_lb.id
  name                = "lb-http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_virtual_machine_scale_set" "vm_scale_set" {
  name                = "test-scale-set"
  location            = var.group_location
  resource_group_name = var.group_name

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Automatic"

  #rolling_upgrade_policy {
  #  max_batch_instance_percent              = 20
  #  max_unhealthy_instance_percent          = 20
  #  max_unhealthy_upgraded_instance_percent = 5
  #  pause_time_between_batches              = "PT0S"
  #}

  #health_probe_id = azurerm_lb_probe.lb_probe.id

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 1
  }

  storage_profile_image_reference {
    id = "/subscriptions/ef314f22-873a-4fce-8baa-74af90e23731/resourceGroups/Containers/providers/Microsoft.Compute/images/kickscooter-image"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  #storage_profile_data_disk {
  #  lun           = 0
  #  caching       = "ReadWrite"
  #  create_option = "Empty"
  #  disk_size_gb  = 30
  #}

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
      name                                   = "as-ip-configuration"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_be_add_pool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lb_nat_pool.id]
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
