# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------

output "server_access" {
  value = "https://${module.compute.server_public_ip}"
}
output "server_local_fqdn" {
  value = module.compute.server_local_address
}

output "flow_logs_bucket_name" {
  value = module.network.flow_logs.bucket
}
output "windows_clients" {
  value = module.compute.windows_clients_list
}

output "linux_clients" {
  value = module.compute.linux_clients_list
}
output "custom_clients" {
  value = module.compute.custom_clients_list
}

