resource "random_password" "vm_password" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  length = 16
  special = true
  override_special = "_%@"
}
resource "random_id" "storage_name" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}