terraform {
  backend "azurerm" {
    resource_group_name  = "rg-shared-mgmt-francecentral-001"
    storage_account_name = "sttfstatefncstg002"
    container_name       = "tfstate"
    key                  = ""
  }

  required_providers {
    azurerm = {
      version = "~> 3.2"
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = "France Central"
  name     = "tf-test-github-actions"
}
