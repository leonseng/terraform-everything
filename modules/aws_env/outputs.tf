output "vpc_id" {
  value = aws_vpc.this.id
}

output "default_route_table_id" {
  description = "Default route table ID of VPC"
  value       = aws_vpc.this.default_route_table_id
}


output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "workload_private_ip" {
  value = aws_instance.workload.private_ip
}

output "workload_private_dns" {
  value = aws_instance.workload.private_dns
}
