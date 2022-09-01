variable "name" {
  description = "Module name"
  type        = string
}

variable "vpc_cidr" {
  description = "Primary CIDR in VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az" {
  description = "Availability zone"
  type        = string
}

variable "public_subnet" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.11.0/24"
}

variable "ingress_allowed_cidrs" {
  description = "CIDR ranges allowed on security group ingress rule"
  type        = list(string)
  default     = ["10.0.11.0/24"]
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
