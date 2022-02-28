output "client_a_ip" {
  value = aws_instance.client_a.public_ip
}

output "server_a_ip" {
  value = aws_instance.server_a.public_ip
}

output "node_a_hostname" {
  value = data.aws_instance.node_a.private_dns
}

output "node_a_private_ip" {
  value = data.aws_instance.node_a.private_ip
}

output "client_b_ip" {
  value = aws_instance.client_b.public_ip
}

output "server_b_ip" {
  value = aws_instance.server_b.public_ip
}

output "node_b_hostname" {
  value = data.aws_instance.node_b.private_dns
}

output "node_b_private_ip" {
  value = data.aws_instance.node_b.private_ip
}

output "app_url" {
  value = local.service_fqdn
}