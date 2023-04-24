locals {
  app_port = 80
}

resource "azurerm_container_app" "receiver" {
  name                         = "receiver"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.rg_name
  revision_mode                = "Single"
  tags = merge(var.tags, {
    "azd-service-name" = "receiver"
  })

  identity {
    type         = "UserAssigned"
    identity_ids = [var.container_registry_pull_identity_id]
  }

  ingress {
    external_enabled = true
    target_port      = local.app_port
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dynamic "registry" {
    for_each = var.service_receiver_image_name == "" ? [] : [1]

    content {
      server   = var.container_registry_endpoint
      identity = var.container_registry_pull_identity_id
    }
  }

  dynamic "dapr" {
    for_each = var.service_receiver_image_name == "" ? [] : [1]

    content {
      app_id       = "receiver"
      app_port     = local.app_port
      app_protocol = "http"
    }
  }

  template {
    container {
      name   = "receiver"
      image  = var.service_receiver_image_name == "" ? "nginx" : var.service_receiver_image_name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "APP_PORT"
        value = local.app_port
      }

      liveness_probe {
        transport = "HTTP"
        port      = local.app_port
        path      = var.service_receiver_image_name == "" ? "" : "health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = local.app_port
        path      = var.service_receiver_image_name == "" ? "" : "health"
      }
    }
  }
}
