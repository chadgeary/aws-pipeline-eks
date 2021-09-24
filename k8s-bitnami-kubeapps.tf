resource "kubernetes_namespace" "kubeapps" {
  metadata {
    name = "kubeapps"
  }
}

resource "helm_release" "kubeapps" {
  namespace  = kubernetes_namespace.kubeapps.metadata.0.name
  wait       = true
  timeout    = 600
  name       = "kubeapps"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubeapps"
}
