resource "azurerm_container_app" "sender" {
  name                         = "sender"
  container_app_environment_id = module.aca.CONTAINER_APP_ENV_ID
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [module.acr.CONTAINER_REGISTRY_PULL_IDENTITY_ID]
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  dynamic "registry" {
    for_each = var.service_sender_image_name == "" ? [] : [1]

    content {
      server   = module.acr.CONTAINER_REGISTRY_ENDPOINT
      identity = module.acr.CONTAINER_REGISTRY_PULL_IDENTITY_ID
    }
  }

  dynamic "dapr" {
    for_each = var.service_sender_image_name == "" ? [] : [1]

    content {
      app_id       = "sender"
      app_port     = 80
      app_protocol = "http"
    }
  }

  template {
    container {
      name   = "sender"
      image  = var.service_sender_image_name == "" ? "nginx" : var.service_sender_image_name
      cpu    = 0.25
      memory = "0.5Gi"

      liveness_probe {
        transport = "HTTP"
        port      = 80
        path      = var.service_sender_image_name == "" ? "" : "health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = 80
        path      = var.service_sender_image_name == "" ? "" : "health"
      }
    }
  }
}
