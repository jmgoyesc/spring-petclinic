# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

// Azure AKS
resource "azurerm_resource_group" "petclinic" {
  name     = "rg-petclinic"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "petclinic" {
  name                = "aks-petclinic"
  location            = azurerm_resource_group.petclinic.location
  resource_group_name = azurerm_resource_group.petclinic.name
  dns_prefix          = "aks-petclinic"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.petclinic.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.petclinic.kube_config_raw
  sensitive = true
}

// Kubernetes
provider "kubernetes" {
  host = azurerm_kubernetes_cluster.petclinic.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.petclinic.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.petclinic.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.petclinic.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_deployment" "petclinic" {
  metadata {
    name = "petclinic"
    labels = {
      app = "petclinic"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "petclinic"
      }
    }
    template {
      metadata {
        labels = {
          app = "petclinic"
        }
      }
      spec {
        container {
          image = "jmgoyesc/juan-goyes-petclinic:25"
          name  = "petclinic"

          port {
            container_port = 8080
          }

          env {
            name = "SERVER_PORT"
            value = "8080"
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "petclinic" {
  metadata {
    name = "petclinic"
  }
  spec {
    selector = {
      app = kubernetes_deployment.petclinic.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.petclinic.status.0.load_balancer.0.ingress.0.ip
}
