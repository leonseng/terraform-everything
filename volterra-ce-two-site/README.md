# Volterra CE Two Site Demo

Demo showing application connectivity between 2 existing AWS VPCs.

Deploy nodes into each of the two existing AWS VPCs, with client and server pre-deployed.

Each server has a [f5-demo-httpd]https://github.com/f5devcentral/f5-demo-httpd) Docker container deployed, listening on port 80.

## How to

Create a `terraform.tfvars` file, providing values to variables listed in [variables.tf](./variables.tf). Then, run `terraform apply -auto-approve`.

## Demo

Client in site A sends request to Mesh node in the same site.
```
REQ_CMD="while true; do \
  curl -s $(terraform output -raw app_url)/txt \
    --resolve $(terraform output -raw app_url):80:$(terraform output -raw node_a_private_ip) \
    | grep Node; \
  sleep 1;
  done"
ssh ec2-user@$(terraform output -raw client_a_ip) $REQ_CMD
```

Traffic should be forwarded to both sites. Example output:
```
      Node Name: Site A
      Node Name: Site A
      Node Name: Site A
      Node Name: Site B
      Node Name: Site A
      Node Name: Site B
      Node Name: Site A
      Node Name: Site B
      Node Name: Site A
      Node Name: Site B
```
