variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_id" {
  type = string
}

variable "argocd_app_of_apps_repo_source" {
  description = "Repository containing Argo CD Application resources to be deployed in the cluster. GitHub private repositories can be accessed via Personal Access Tokens."
  type = object({
    repo_url                 = string
    path                     = string
    gh_username              = string
    gh_personal_access_token = string
  })
  default = {
    repo_url                 = "https://github.com/leonseng/terraform-everything.git"
    path                     = "eks-gitops/argocd/demo/argocd-apps"
    gh_username              = "nobody"
    gh_personal_access_token = null
  }
}
