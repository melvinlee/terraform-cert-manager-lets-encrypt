variable "cloudflare_email" {}
variable "cloudflare_token" {}

// domain
variable "cloudflare_zone" {}
variable "domain_ttl" {
  default = 300
}


provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}


data local_file "lb_ip" {
  filename   = "${path.root}/runtime/lb_ip.txt"
  depends_on = [
    "helm_release.nginx_ingress"
  ]
}


resource "cloudflare_record" "tld" {
  domain = "${var.cloudflare_zone}"
  name   = "${var.cloudflare_zone}"
  value  = "${data.local_file.lb_ip.content}"
  type   = "A"
  ttl    = "${var.domain_ttl}"
}

resource "cloudflare_record" "www" {
  domain = "${var.cloudflare_zone}"
  name   = "www"
  value  = "${data.local_file.lb_ip.content}"
  type   = "A"
  ttl    = "${var.domain_ttl}"
}

resource "cloudflare_record" "wildcard" {
  domain = "${var.cloudflare_zone}"
  name   = "*"
  value  = "${data.local_file.lb_ip.content}"
  type   = "A"
  ttl    = "${var.domain_ttl}"
}
