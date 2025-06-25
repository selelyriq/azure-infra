data "azurerm_network_watcher" "nw" {
  name                = "NetworkWatcher_${azurerm_resource_group.rg.location}"
  resource_group_name = "NetworkWatcherRG"
}

resource "azurerm_network_connection_monitor" "cm" {
  name               = "cm-peering-test"
  network_watcher_id = data.azurerm_network_watcher.nw.id
  location           = data.azurerm_network_watcher.nw.location

  endpoint {
    name               = "database"
    target_resource_id = azurerm_private_endpoint.my_terraform_private_endpoint.private_service_connection.0.private_ip_address
  }

  endpoint {
    name    = "spoke-vm"
    address = azurerm_network_interface.nic.private_ip_address
  }

  test_configuration {
    name     = "icmp-test"
    protocol = "Icmp"
    icmp_configuration {

    }
  }

  test_group {
    name                     = "hub-to-spoke-ssh"
    destination_endpoints    = ["spoke-vm"]
    source_endpoints         = ["hub-vm"]
    test_configuration_names = ["icmp-test"]
  }

  depends_on = [
    azurerm_mssql_server.mssql_server,
    azurerm_virtual_machine_extension.vm_nw_agent,
  ]
}