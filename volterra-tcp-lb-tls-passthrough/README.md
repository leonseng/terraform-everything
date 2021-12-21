# Volterra TCP Loadbalancer with TLS passthrough

Creates a TCP loadbalancer on Volterra which performs TLS passthrough to the origin server.

An example use case is to reuse the origin server's TLS certificates while tapping into Volterra's security and observability features.

See [variables.tf](./variables.tf) for a list of input variables.

```
terraform init
export VES_P12_PASSWORD=<Volterra API cert password>
terraform apply -auto-approve
```

Once the proxy has been created, it is necessary to create a DNS CNAME record to point the server FQDN to the TCP loadbalancer `host_name`. This is to ensure the correct SNI value is set in the request, which will be passed on by Volterra to the origin server.
