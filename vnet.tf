resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-vnet"
  location = "eastus"
}

###
# Hub VNet
###

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-terraform-hub"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "hub-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_interface" "nic_hub" {
  name                = "nic-terraform-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ip-config"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_hub_nsg" {
  network_interface_id      = azurerm_network_interface.nic_hub.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

###
# App VNet
###

resource "azurerm_virtual_network" "app_vnet" {
  name                = "vnet-terraform"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "subnet_2" {
  name                 = "subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ip-config"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

###
# DB VNet
###

resource "azurerm_virtual_network" "db_vnet" {
  name                = "vnet-terraform-db"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg_db.location
  resource_group_name = azurerm_resource_group.rg_db.name
}

resource "azurerm_subnet" "subnet_db" {
  name                 = "subnet-db"
  resource_group_name  = azurerm_resource_group.rg_db.name
  virtual_network_name = azurerm_virtual_network.db_vnet.name
  address_prefixes     = ["10.3.0.0/24"]
}

resource "azurerm_network_interface" "nic_db" {
  name                = "nic-terraform-db"
  location            = azurerm_resource_group.rg_db.location
  resource_group_name = azurerm_resource_group.rg_db.name
  ip_configuration {
    name                          = "ip-config"
    subnet_id                     = azurerm_subnet.subnet_db.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_db_nsg" {
  network_interface_id      = azurerm_network_interface.nic_db.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

###
# Hub VNet Peering
###

resource "azurerm_virtual_network_peering" "hub_peering" {
  name                         = "hub-peering"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.app_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_peering_app" {
  name                         = "hub-peering-app"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.db_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "app_peering" {
  name                         = "app-peering"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.app_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "db_peering" {
  name                         = "db-peering"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.db_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}