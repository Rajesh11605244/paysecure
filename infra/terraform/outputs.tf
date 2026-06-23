output "namespace" {
  value = kubernetes_namespace.paysecure.metadata[0].name
}

output "config_map_name" {
  value = kubernetes_config_map.app_config.metadata[0].name
}
