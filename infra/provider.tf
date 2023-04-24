terraform {
  backend "azurerm" {}
  required_version = "~>1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.53.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      # only keep this setting while evaluating - remove for production
      prevent_deletion_if_contains_resources = false
    }
    application_insights {
      disable_generated_rule = true
    }
    key_vault {
      # only keep this setting while evaluating - remove for production
      purge_soft_delete_on_destroy = true
    }
  }
}

# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
