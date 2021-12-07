
provider "aws" {
  region = var.region
}

resource "random_id" "id" {
  byte_length = 8
}


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

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = var.k8s_version
  cluster_name    = "eks-${random_id.id.hex}"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets

  worker_groups = var.eks_worker_group
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

provider "kubectl" {
  load_config_file       = "false"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

data "http" "argocd_install_manifest_url" {
  url = var.argocd_install_manifest_url
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_install_manifest_url.body
}

resource "kubectl_manifest" "argocd" {
  depends_on         = [kubernetes_namespace.argocd]
  wait               = true
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}
