# EKS GitOps

IaC x GitOps demo using Terraform and Argo CD.

Reference: https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/eks/README.md

```
cd eks
terraform init
terraom apply -auto-approve
export CLUSTER_ID=$(terraform output -raw cluster_id)
export KUBECONFIG=$(pwd)/$(terraform output -raw kubeconfig_file)

cd ../argocd-bootstrap
terraform init
terraform apply -var=cluster_id=$CLUSTER_ID -auto-approve

cd ..
```

Verify
```
# using kubeconfig file specified in KUBECONFIG environment variable
kubectl -n argocd get applications
```

Clean up
```
cd argocd-bootstrap
terraform init
terraform destroy -auto-approve

cd ../eks
terraform init
terraom destroy -auto-approve

cd ..
```

## Notes

- AWS load balancers created by Kubernetes LoadBalanacer Services need to be manually deleted for `terraform delete` to work.

## Todo

[] Expose Argo CD web UI
[] [Switch from app of apps pattern to ApplicationSet](https://itnext.io/level-up-your-argo-cd-game-with-applicationset-ccd874977c4c)
[] Handle orphaned resources (e.g. AWS load balancers) - wait for all ArgoCD applications to be deleted before deleting ArgoCD itself
[] Switch to using Argo CD provider?
[] Deploy Sealed Secrets
