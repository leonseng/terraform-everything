output "aws_bastion_ip" {
  value = module.aws_env.bastion_public_ip
}

output "aws_workload_private_ip" {
  value = module.aws_env.workload_private_ip
}

output "aws_workload_private_dns" {
  value = module.aws_env.workload_private_dns
}

output "azure_bastion_ip" {
  value = module.azure_env.bastion_public_ip
}

output "azure_workload_private_ip" {
  value = module.azure_env.workload_private_ip
}
