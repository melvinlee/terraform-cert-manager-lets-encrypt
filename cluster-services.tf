variable "acme_email" {}
variable "acme_server_url" {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

locals {
  kubeconfig         = "--kubeconfig=\"${path.root}/runtime/${digitalocean_kubernetes_cluster.sentinel.name}-k8s-config.yaml\""
  kubectl            = "kubectl ${local.kubeconfig}"
  get_lb_ip_jsonpath = "-o=jsonpath='{.status.loadBalancer.ingress[0].ip}'"
  runtime            = "${path.root}/runtime"

  cf_token_name = "cloudflare-api-key-secret"
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "stable"
  chart      = "nginx-ingress"
  namespace  = "kube-system"

  set {
    name  = "controller.stats.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "kubernetes_service_account.tiller"
  ]

  provisioner "local-exec" {
    command = "${local.kubectl} -n kube-system get svc nginx-ingress-controller ${local.get_lb_ip_jsonpath} > ${local.runtime}/lb_ip.txt"
  }

}

data "template_file" "cert_manager" {
  template = "${file("${path.module}/cert-manager.tpl.yaml")}"
  vars     = {
    cloudflare_email = "${var.cloudflare_email}"
    cloudflare_token = "${var.cloudflare_token}"
    cloudflare_zone  = "${var.cloudflare_zone}"

    acme_email      = "${var.acme_email}"
    acme_server_url = "${var.acme_server_url}"

    k8s_secret_name = "${local.cf_token_name}"
    k8s_cert_name   = "${replace(var.cloudflare_zone, ".", "-")}"
  }

}

resource "kubernetes_secret" "cf_api_key_secret" {
  "metadata" {
    name      = "${local.cf_token_name}"
    namespace = "kube-system"
  }
  data {
    api-key = "${var.cloudflare_token}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.cert_manager.rendered}\" > ${local.runtime}/cert-manager.yaml"
  }

  depends_on = [
    "helm_release.cert_manager"
  ]

}


resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  repository = "stable"
  namespace  = "kube-system"
  version    = "v0.5.2"

  provisioner "local-exec" {
    command = "${local.kubectl} apply -f ${local.runtime}/cert-manager.yaml"
  }


}


