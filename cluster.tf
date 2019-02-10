//
//locals {
//  kubernetes = {
//    host = "${digitalocean_kubernetes_cluster.sentinel.endpoint}"
//
//  client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.client_certificate)}"
//  client_key             = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.client_key)}"
//  cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.cluster_ca_certificate)}"
//  }
//}

provider "kubernetes" {
  host = "${digitalocean_kubernetes_cluster.sentinel.endpoint}"

  client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.cluster_ca_certificate)}"

}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  "role_ref" {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  "subject" {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}


provider "helm" {
  kubernetes {
    host = "${digitalocean_kubernetes_cluster.sentinel.endpoint}"

    client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.sentinel.kube_config.0.cluster_ca_certificate)}"
  }

  install_tiller  = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"

}

output "kubectl" {
  value = "kubectl --kubeconfig=\"${path.root}/runtime/${digitalocean_kubernetes_cluster.sentinel.name}-k8s-config.yaml\""
}

output "kubeconfig" {
  value = "--kubeconfig=\"${path.root}/runtime/${digitalocean_kubernetes_cluster.sentinel.name}-k8s-config.yaml\""
}