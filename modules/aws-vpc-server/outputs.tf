output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.server.id
}

output "public_ip" {
  description = "Public IPv4 address of the web server."
  value       = aws_instance.server.public_ip
}

output "web_url" {
  description = "URL of the NGINX web page."
  value       = "http://${aws_instance.server.public_ip}"
}

output "ssh_command" {
  description = "Example SSH command; use the private key matching ssh_public_key."
  value       = "ssh ubuntu@${aws_instance.server.public_ip}"
}