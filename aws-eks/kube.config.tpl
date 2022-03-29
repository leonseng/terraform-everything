apiVersion: v1
kind: Config
current-context: default
clusters:
- name: ${cluster_id}
  cluster:
    certificate-authority-data: ${cluster_ca_data}
    server: ${cluster_endpoint}
contexts:
- name: default
  context:
    cluster: ${cluster_id}
    user: terraform
users:
- name: terraform
  user:
    token: ${token}