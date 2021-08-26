resource "kubernetes_namespace" "metrics" {
  metadata {
    name = "metrics"
  }
}

resource "helm_release" "metrics" {
  namespace  = kubernetes_namespace.metrics.metadata.0.name
  wait       = true
  timeout    = 600
  name       = "metrics"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
}
