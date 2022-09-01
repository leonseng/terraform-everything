output "aws_ce_hostname" {
  value = data.aws_instance.ce.private_dns
}

output "aws_ce_private_ip" {
  value = data.aws_instance.ce.private_ip
}
