resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  resource_group_name = var.group_name
  location            = var.group_location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "net_inter" {
  name                = "net-inter"
  resource_group_name = var.group_name
  location            = var.group_location

  ip_configuration {
    name                          = "ips-for-vm"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "terraform-vm"
  resource_group_name = var.group_name
  location            = var.group_location
  size                = "Standard_D4s_v3"
  admin_username      = "teamcity"
  #admin_password        = "Owl123456789"
  network_interface_ids = [azurerm_network_interface.net_inter.id]

  admin_ssh_key {
    username   = "teamcity"
    public_key = file("/root/.ssh/.tc/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  connection {
    host        = azurerm_public_ip.vm_public_ip.ip_address
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

resource "local_file" "vm_ip" {
  content  = azurerm_linux_virtual_machine.vm.private_ip_address
  filename = "vm_ip_priv.txt"
}
