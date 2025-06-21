resource "azurerm_dns_zone" "dns_zone" {
  name                = "terraform.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "dns_a_record" {
  name                = "www"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_public_ip.public_ip.ip_address]
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "terraform.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = "www"
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.my_terraform_private_endpoint.private_service_connection.0.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link_hub" {
  name                  = "terraform-network-link-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link_app" {
  name                  = "terraform-network-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.app_vnet.id
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = "terraform-network-link-db"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.db_vnet.id
  registration_enabled  = false
}