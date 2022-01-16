# Volterra AWS VPC Site

Defines an AWS VPC site on Volterra, and automatically runs Terraform apply/destroy through `local-exec` to provision/decommision the site.

Uses P12 file to authenticate, hence requires `VES_P12_PASSWORD` environment variable to be set.
