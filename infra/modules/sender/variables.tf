variable "location" {
  type        = string
  default     = "eastus"
  description = "Desired Azure Region"
}

variable "rg_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "service_sender_image_name" {
  type        = string
  default     = "nginx"
  description = "Image name/tag of sender service."
}

variable "container_app_environment_id" {
    type = string
}

variable "container_registry_endpoint" {
    type = string
}

variable "container_registry_pull_identity_id" {
    type = string
}
