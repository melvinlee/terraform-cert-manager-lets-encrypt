# terraform-cert-manager-lets-encrypt
Terraform config to set up a kubernetes cluster with lets encrypt


You'll need:

```
do_token = "" # digital ocean token
region = "" # your preferred region, default is sfo2

cloudflare_email = "" # your cloudflare email
cloudflare_token = "" # cloudflare api token
cloudflare_zone = "" # the domain you're using

# default is staging
#acme_server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
#acme_server_url = "https://acme-v02.api.letsencrypt.org/directory"
acme_email = ""
```


```bash
mkdir runtime
terraform init
terraform apply
```

