terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-paysecure"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type    = string
  default = "paysecure"
}

resource "kubernetes_namespace" "paysecure" {
  metadata {
    name = "${var.app_name}-${var.environment}"
    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.paysecure.metadata[0].name
  }
  data = {
    ENVIRONMENT     = var.environment
    KAFKA_TOPIC     = "payments.raw"
    FRAUD_THRESHOLD = "10000"
    LOG_LEVEL       = "info"
  }
}
