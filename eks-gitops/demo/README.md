# Argo CD Demo

Sample directory structure for storing Argo CD Application definitons.

To bootstrap the Kubernetes cluster, applications in the cluster are deployed via the [App of Apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern), where a single master Argo CD Application resource is used to reference another repository ([argocd-apps](./argocd-apps) in this case) containing the Application resources for all other apps.

The Application resources within [argocd-apps](./argocd-apps) then further reference repositories that contains the Kubernetes resources for the individual applications (see [nginx](./nginx) and [httpbin](./httpbin) for examples).
