resource "azurerm_log_analytics_workspace" "log" {
  name                = "log${var.resource_token}"
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}
