resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false
  override_special = "/@£$"
}

resource "azurerm_storage_account" "storage" {
  name                     = "stacctf${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "container-terraform"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "blob-terraform"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "file.txt"
  content_type           = "text/plain"
}
