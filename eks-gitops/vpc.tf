data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name   = "region-name"
    values = ["${var.region}"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-gitops-${random_id.id.hex}"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.local_az.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    id = random_id.id.hex
  }
}
