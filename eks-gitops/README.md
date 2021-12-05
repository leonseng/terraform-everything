# EKS GitOps

IaC x GitOps demo using Terraform and Argo CD.

## Notes

- AWS load balancers created by Kubernetes LoadBalanacer Services need to be manually deleted for `terraform delete` to work.

## Todo

[] Expose Argo CD web UI
[] [Switch from app of apps pattern to ApplicationSet](https://itnext.io/level-up-your-argo-cd-game-with-applicationset-ccd874977c4c)
[] Handle orphaned resources (e.g. AWS load balancers) - wait for all ArgoCD applications to be deleted before deleting ArgoCD itself
[] Switch to using Argo CD provider?
[] Deploy Sealed Secrets
