# Volterra HTTP proxy

Creates a HTTP loadbalancer on Volterra which proxies traffic to the origin server.

See [variables.tf](./variables.tf) for a list of input variables.

```
terraform init
export VES_P12_PASSWORD=<Volterra API cert password>
terraform apply -auto-approve
```

Once the proxy has been created, it is necessary to create the following DNS records:

1. a CNAME record as stated in the HTTP loadbalancer `spec.auto_cert_info.dns_records` .
1. an A record pointing the service FQDN (e.g. `foo.bar.com`) to the HTTP loadbalancer VIP `spec.dns_info[0].ip_address`
