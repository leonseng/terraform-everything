# EKS GitOps

IaC x GitOps demo using Terraform and Argo CD.

The setup is split into 2 parts:

1. [Deploy an EKS cluster on AWS](./eks.tf)
1. [Install Argo CD on EKS cluster and create bootstrap Application to deploy applications using app of apps pattern ](./argocd.tf)

## Deploy
```
terraform init
terraform apply -auto-approve
export KUBECONFIG=$(terraform output -raw kubeconfig_file)
```

## Verify
```
# using kubeconfig file specified in KUBECONFIG environment variable
kubectl -n argocd get applications
```

## Clean up
```
terraform destroy -auto-approve
```

## Todo

[] Expose Argo CD web UI
[] [Switch from app of apps pattern to ApplicationSet](https://itnext.io/level-up-your-argo-cd-game-with-applicationset-ccd874977c4c)
[] Handle orphaned resources (e.g. AWS load balancers) - wait for all ArgoCD applications to be deleted before deleting ArgoCD itself
[] Switch to using Argo CD provider?
[] Deploy Sealed Secrets
