# EKS GitOps

IaC x GitOps demo using Terraform and Argo CD.

The setup is split into 2 parts:

1. [Kubernetes cluster](./eks)

    Deploys an EKS cluster on AWS

1. [Argo CD](./argocd/install)

    Installs Argo CD in the `argocd` namespace on the Kubernetes cluster and deploys an Argo CD Application resource which deploys all other applications in the cluster.

    Split from previous step as Terraform Kubernetes provider configuration must be known (after EKS has been created) before the provider can apply configurations. See [Terraform documentation](https://github.com/hashicorp/terraform-provider-kubernetes/tree/main/_examples/eks) for more information.

## Deploy

```
root_dir=$(pwd)

# Deploy EKS cluster
cd $root_dir/eks
terraform init
terraform apply -auto-approve
export KUBECONFIG=$(pwd)/$(terraform output -raw kubeconfig_file)

# Install Argo CD and deploy bootstrap application
cd $root_dir/argocd/install
terraform init
terraform apply -var=kubeconfig_file=$KUBECONFIG -auto-approve
```

## Verify
```
# using kubeconfig file specified in KUBECONFIG environment variable
kubectl -n argocd get applications
```

## Clean up
```
# Uninstall Argo CD
cd $root_dir/argocd/install
terraform destroy -var=kubeconfig_file=$KUBECONFIG -auto-approve

# Destroy EKS cluster
cd $root_dir/eks
terraform destroy -auto-approve
```

## Todo

[] Expose Argo CD web UI
[] [Switch from app of apps pattern to ApplicationSet](https://itnext.io/level-up-your-argo-cd-game-with-applicationset-ccd874977c4c)
[] Handle orphaned resources (e.g. AWS load balancers) - wait for all ArgoCD applications to be deleted before deleting ArgoCD itself
[] Switch to using Argo CD provider?
[] Deploy Sealed Secrets
