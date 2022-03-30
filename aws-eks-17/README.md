# AWS EKS Terraform example

Deploys an EKS cluster with Terraform

## Deploy
```
terraform init
terraform apply -auto-approve
kubectl --kubeconfig <(terraform output -raw kubeconfig_file) get nodes
```

## Clean up
```
terraform destroy -auto-approve
```
