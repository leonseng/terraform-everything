variable "api_endpoint" {
  description = "Tenant API url"
  type        = string
}

variable "api_p12_file" {
  description = "API credential p12 file path"
  type        = string
}

variable "namespace" {
  description = "Namespace to create objects in"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key for deploying Voltstack site"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key for deploying Voltstack site"
  type        = string
}

variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "ec2_ami" {
  description = "AMI ID for customer EC2"
  type        = string
  default     = "ami-0c635ee4f691a2310" # ap-southeast-2 Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

variable "ssh_public_key" {
  description = "SSH public key to be added onto all EC2 instances"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDNAVhes9z/HUfoiKDpyE2vD9ALtfMSVJ/mc1WkJjTeYTEUnVYZ/TjLiPXPmwhT5Jzp6S8kveeeBM77y6mlReOkefdDRmmuZL8MMPt3dn0lSI6GC11GndlxEBe47eKJ2B5pq36W8nveJH7Wek96YzQsJT9XqzKE9H38IWsaoy+mqbMjBEBdfE1eTCUbxtQinjJq2eVvinhsezzS3LlAgGk0tk5ZwX0UeYze4PA4znK7ppu9Epb8NYqYlRPYud7b1O5w1+7SKq1QGZRI5x9Qw+gXRRASGV1rRlTrSxUSWyMiXQMahr0QqAw+7r1jEJPS4/9QeEIBlLmWqBV2px9JI0PvseGNbX1XPB/WB4uw19aqF6Bbg51KGqsz4iRSjxLiHbIHeW+ttEbyMbAjpYFSNjOCgD2aL8kIBcjoQxS7azcs0RdWuIMoFRJYyvmQklMtQK9dClQQ4rHlR/G4wBevFayH7PthH8OIbwOaJ/lgk/yEMjMYcKetfzioA4rWhDS/vM="
}
