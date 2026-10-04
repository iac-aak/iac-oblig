terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.7"
    }
  }
}

locals {
  vm_name = format("vm-%s", var.base_name)
}

resource "azurerm_network_interface" "nic" {
  name                = format("nic-%s", var.base_name)
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Linux med SSH-nøkkel, så det ikke ligger noe passord i state.
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.vm_name
  computer_name         = local.vm_name
  location              = var.location
  resource_group_name   = var.rg_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}
