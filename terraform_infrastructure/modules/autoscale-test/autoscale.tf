resource "azurerm_virtual_machine_scale_set" "vm_scale_set" {
  name                = "test-scale-set"
  location            = var.group_location
  resource_group_name = var.group_name

  upgrade_policy_mode = "Rolling"

  sku {
    name     = "Standard_D4s_v3"
    tier     = "Standard"
    capacity = 3
  }

  storage_profile_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 20
  }

  os_profile {
    computer_name_prefix = "scale-vm"
    admin_username       = "teamcity"
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
      application_gateway_backend_address_pool_ids = var.as_backends_add_pool
    }
  }

  connection {
    host        = azurerm_virtual_machine_scale_set.vm_scale_set.private_ip_address
    type        = "ssh"
    user        = "teamcity"
    private_key = file("/root/.ssh/.tc/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y upgrade ",
      "sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable'",
      "sudo apt update",
      "sudo apt -y install docker-ce docker-ce-cli containerd.io",
      "sudo curl -L 'https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
    ]
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
      maximum = 3
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
        threshold          = 5
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
