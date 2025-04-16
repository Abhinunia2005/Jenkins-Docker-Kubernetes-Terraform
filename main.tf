terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.0.0"
}

provider "azurerm" {
  subscription_id = "fbbf2c3a-bb8f-4058-8e4b-6986bff47cc2"
  tenant_id       = "85c34981-89f9-4692-b9ec-720e6a7c2ee4"
  features {}
}

# Variables
variable "location" {
  default = "East US2"
}

variable "resource_group_name" {
  default = "myResourceGroup8414"
}

variable "acr_name" {
  default = "abhi8414" 
}

variable "aks_cluster_name" {
  default = "myAKSCluster8414"
}

variable "dns_prefix" {
  default = "myakscluster8414"
}

variable "node_count" {
  default = 2
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "Development"
  }
}

# Role assignment to allow AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = "3e089cfc-94bb-4765-bcc5-a0aae9cface7"
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id

 
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
