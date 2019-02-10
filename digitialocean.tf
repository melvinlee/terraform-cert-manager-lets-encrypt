variable "do_token" {}
variable "region" {
  default = "sfo2"
}

variable "doks_version" {
  default = "1.13.1-do.2"
}


provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_kubernetes_cluster" "sentinel" {
  name    = "sentinel-cluster"
  region  = "${var.region}"
  version = "${var.doks_version}"

  node_pool {
    name       = "worker-pool"
    node_count = 3
    size       = "s-2vcpu-2gb"
  }

  provisioner "local-exec" {
    command = "echo \"${digitalocean_kubernetes_cluster.sentinel.kube_config.0.raw_config}\" > runtime/${digitalocean_kubernetes_cluster.sentinel.name}-k8s-config.yaml"
  }

}

output "cluster-config" {
  value = "${digitalocean_kubernetes_cluster.sentinel.kube_config.0.raw_config}"
  sensitive = true
}
