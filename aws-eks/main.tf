provider "aws" {
  region = var.region
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "tf-eks-"
}

# data "aws_region" "current" {}

data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name = "region-name"
    # values = ["${data.aws_region.current.name}"]
    values = [var.region]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = random_id.id.dec
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.local_az.names, 0, 3)
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.15.0"

  cluster_version = var.k8s_version
  cluster_name    = random_id.id.dec
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  eks_managed_node_groups = {
    node_group = var.eks_managed_node_group_configuration
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

locals {
  kubeconfig = templatefile(
    abspath("${path.module}/kube.config.tpl"),
    {
      cluster_id       = module.eks.cluster_id
      cluster_ca_data  = module.eks.cluster_certificate_authority_data
      cluster_endpoint = module.eks.cluster_endpoint
      token            = data.aws_eks_cluster_auth.eks.token
    }
  )
}
