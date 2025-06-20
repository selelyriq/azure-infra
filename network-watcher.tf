resource "azurerm_network_watcher" "nw" {
  name                = "nw-${azurerm_resource_group.rg.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_connection_monitor" "cm" {
  name               = "cm-peering-test"
  network_watcher_id = azurerm_network_watcher.nw.id
  location           = azurerm_network_watcher.nw.location

  endpoint {
    name = "hub-vm"
    target_resource_id = azurerm_linux_virtual_machine.hub_test_vm.id
  }

  endpoint {
    name = "spoke-vm"
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
    azurerm_virtual_machine_extension.hub_test_vm_nw_agent,
    azurerm_virtual_machine_extension.vm_nw_agent,
  ]
}