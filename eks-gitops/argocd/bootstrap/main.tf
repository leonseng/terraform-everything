provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_secret" "gh_pat" {
  count = var.argocd_app_of_apps_repo_source.gh_personal_access_token == null ? 0 : 1
  metadata {
    name      = "argocd-repo-auth"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.argocd_app_of_apps_repo_source.repo_url
    username = var.argocd_app_of_apps_repo_source.gh_username
    password = var.argocd_app_of_apps_repo_source.gh_personal_access_token
  }
}

resource "kubernetes_manifest" "application_argocd_app_of_apps" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io",
      ]
      "name"      = "app-of-apps"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "path"           = var.argocd_app_of_apps_repo_source.path
        "repoURL"        = var.argocd_app_of_apps_repo_source.repo_url
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {
          "allowEmpty" = true
          "prune"      = true
          "selfHeal"   = true
        }
        "syncOptions" = [
          "Validate=false",
        ]
      }
    }
  }
}
