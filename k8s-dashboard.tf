resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "dashboard"
  }
}

resource "helm_release" "dashboard" {
  namespace  = kubernetes_namespace.dashboard.metadata.0.name
  wait       = true
  timeout    = 600
  name       = "dashboard"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubeapps"
}
