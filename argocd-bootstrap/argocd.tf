resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

data "http" "argocd_install_manifest_url" {
  url = var.argocd_install_manifest_url
}

############################################################################
# Install Argo CD from manifest URL
############################################################################
data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_install_manifest_url.body
}

resource "kubectl_manifest" "argocd" {
  depends_on         = [kubernetes_namespace.argocd]
  wait               = true
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = var.argocd_namespace
}

############################################################################
# Expose argo CD web UI on public Load balancer
############################################################################
resource "kubernetes_service" "argocd_server_lb" {
  depends_on = [kubectl_manifest.argocd]

  metadata {
    name      = "argocd-server-lb"
    namespace = var.argocd_namespace
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "argocd-server"
    }
    port {
      name        = "https"
      port        = 443
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

# Get Argo CD web UI IP/URL
data "kubernetes_service" "argocd_server_lb" {
  depends_on = [kubernetes_service.argocd_server_lb]

  metadata {
    name      = "argocd-server-lb"
    namespace = var.argocd_namespace
  }
}

# Get web UI password
data "kubernetes_secret" "argocd_server_password" {
  depends_on = [null_resource.argocd_app_cleanup]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }
}

############################################################################
# Deploy Argo CD bootstrap Application that will install other Applications
############################################################################
# This ensures all Argo CD Application CRs are deleted before Argo CD installation is removed (along with the Application CRD).
# Without this, the deletion of Application CRs will be stuck if the Application CRD is deleted before the CRs are cleaned up,
# as the status of the CRs cannot be queried without the CRD
resource "null_resource" "argocd_app_cleanup" {
  depends_on = [kubernetes_service.argocd_server_lb]
  triggers = {
    kubeconfig_file  = var.kubeconfig_file
    argocd_namespace = var.argocd_namespace
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<SCRIPT
until [ $( \
  kubectl get applications \
    --kubeconfig ${self.triggers.kubeconfig_file} \
    -n ${self.triggers.argocd_namespace} \
    --no-headers \
  2>/dev/null \
  | wc -l \
) -eq 0 ]; do
sleep 10;
done
SCRIPT
  }
}

# Optionally create a Secret for Argo CD to pull from private Git repository
resource "kubernetes_secret" "private_repo_auth" {
  depends_on = [null_resource.argocd_app_cleanup]
  count      = var.bootstrap_app_source_repo.password == null ? 0 : 1
  metadata {
    name      = "private-repo-auth"
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.bootstrap_app_source_repo.url
    username = var.bootstrap_app_source_repo.username
    password = var.bootstrap_app_source_repo.password
  }
}

# need to use kubectl_manifest here because kubernetes_manifest does not support defining CRD and CR in the same TF state
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "kubectl_manifest" "bootstrap_app" {
  depends_on = [null_resource.argocd_app_cleanup]
  wait       = true
  yaml_body = templatefile(
    abspath("${path.module}/bootstrap-app.yaml.tpl"),
    {
      argocd_namespace = var.argocd_namespace
      url              = var.bootstrap_app_source_repo.url
      revision         = var.bootstrap_app_source_repo.revision
      path             = var.bootstrap_app_source_repo.path
    }
  )
}
