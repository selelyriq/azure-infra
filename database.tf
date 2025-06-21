resource "azurerm_resource_group" "rg_db" {
  name     = "rg-terraform-db"
  location = "eastus2"
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = "mssql-terraform"
  location                     = azurerm_resource_group.rg_db.location
  resource_group_name          = azurerm_resource_group.rg_db.name
  administrator_login          = "adminuser"
  administrator_login_password = "Password1234!"
  version                      = "12.0"
}

resource "azurerm_mssql_database" "mssql_database" {
  name           = "mssql-terraform-db"
  server_id      = azurerm_mssql_server.mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
}

#Create private endpoint for SQL Server
resource "azurerm_private_endpoint" "my_terraform_private_endpoint" {
  name                = "private-endpoint-sql1"
  location            = azurerm_resource_group.rg_db.location
  resource_group_name = azurerm_resource_group.rg_db.name
  subnet_id           = azurerm_subnet.subnet_db.id

  private_service_connection {
    name                           = "private-endpoint-connection-sql1"
    private_connection_resource_id = azurerm_mssql_server.mssql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone.id]
  }
}