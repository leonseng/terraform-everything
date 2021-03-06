provider "aws" {
  region = var.region
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  cluster_name = "eks-${random_id.id.hex}"
}

data "aws_region" "current" {}

data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name   = "region-name"
    values = ["${data.aws_region.current.name}"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "eks-gitops-${random_id.id.hex}"
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.local_az.names, 0, 3)
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version                            = var.k8s_version
  cluster_name                               = local.cluster_name
  vpc_id                                     = module.vpc.vpc_id
  subnets                                    = module.vpc.private_subnets
  kubeconfig_aws_authenticator_command       = "aws"
  kubeconfig_aws_authenticator_command_args  = ["eks", "get-token", "--cluster-name", local.cluster_name]
  kubeconfig_aws_authenticator_env_variables = var.kubeconfig_aws_auth_env_variables
  worker_groups                              = var.eks_worker_group
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
