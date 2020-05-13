resource "azurerm_storage_account" "store" {
  name                     = "tfsta${lower(random_id.storage_name.hex)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
      type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "scripts" {
  name                  = local.storage_container_name
  storage_account_name  = azurerm_storage_account.store.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "installchoc" {
  name                   = "InstallChocolateyComponents.ps1"
  storage_account_name   = azurerm_storage_account.store.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "${path.module}/scripts/InstallChocolateyComponents.ps1"
}