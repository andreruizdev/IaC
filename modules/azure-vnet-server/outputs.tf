output "resource_group_name" {
  description = "Name of the resource group containing the module resources."
  value       = azurerm_resource_group.this.name
}

output "public_ip" {
  description = "Static public IPv4 address of the web server."
  value       = azurerm_public_ip.server.ip_address
}

output "web_url" {
  description = "URL of the NGINX web page."
  value       = "http://${azurerm_public_ip.server.ip_address}"
}

output "ssh_command" {
  description = "Example SSH command; use the private key matching admin_ssh_public_key."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.server.ip_address}"
}