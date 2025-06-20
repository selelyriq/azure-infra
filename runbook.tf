resource "azurerm_automation_account" "automation_account" {
    name = "automation-account-terraform"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "Basic"
}

resource "azurerm_automation_runbook" "runbook" {
    name = "runbook-terraform"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    automation_account_name = azurerm_automation_account.automation_account.name
    log_verbose = true
    log_progress = true
    runbook_type = "Python3"
    
    publish_content_link {
        uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-automation-runbook-python-function/automation.py"
    }

    tags = {
        environment = "Development"
    }
}