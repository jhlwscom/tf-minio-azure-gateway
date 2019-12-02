provider "azurerm" {
  subscription_id= var.subscription
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_storage_account" "minio" {
  name                = "${var.prefix}sa"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "minio" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "minio" {
  name                = "${var.prefix}-as"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.minio.id

  site_config {
    app_command_line = "gateway azure"
    linux_fx_version = "DOCKER|minio/minio:latest"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "MINIO_ACCESS_KEY"                    = azurerm_storage_account.minio.name
    "MINIO_SECRET_KEY"                    = azurerm_storage_account.minio.primary_access_key
    "PORT"                                = "9000"
  }
}
