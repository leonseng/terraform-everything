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
