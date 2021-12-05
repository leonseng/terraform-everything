# EKS GitOps

IaC x GitOps demo using Terraform and Argo CD.

## Notes

- AWS load balancers created by Kubernetes LoadBalanacer Services need to be manually deleted for `terraform delete` to work.

## Todo

[] Expose Argo CD web UI
[] Switch to using Argo CD provider?
[] Deploy Sealed Secrets
