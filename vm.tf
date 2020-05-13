resource "azurerm_public_ip" "vm" {
  name                = local.vm_publicip
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "vm" {
  name                = local.vm_nsg
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm.name
}


resource "azurerm_network_interface" "vm" {
  name                = local.vm_nic
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = local.vm_ipconfig
    public_ip_address_id          = azurerm_public_ip.vm.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vm.id
    primary = true
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_virtual_machine" "vm" {
  name                  = local.vm_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [
        azurerm_network_interface.vm.id
    ]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = local.vm_disk
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = local.vm_name
    admin_username = var.vm_username
    admin_password = random_password.vm_password.result
  }
  os_profile_windows_config {
      provision_vm_agent        = true
  }

  identity {
      type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "storageblobreader" {
  scope                = azurerm_storage_account.store.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_virtual_machine.vm.identity[0].principal_id
}

resource "azurerm_virtual_machine_extension" "installchocolatey" {
  name                 = "installchocolatey"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "fileUris": [
            "${azurerm_storage_blob.installchoc.url}"
        ]        
    }
SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File InstallChocolateyComponents.ps1",
        "managedIdentity" : {}
    }
    PROTECTED_SETTINGS

    lifecycle {
        ignore_changes = all
    }
}