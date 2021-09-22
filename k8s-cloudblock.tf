resource "kubernetes_namespace" "cloudblock" {
  metadata {
    name = "cloudblock"
  }
}

resource "helm_release" "cloudblock" {
  namespace = kubernetes_namespace.cloudblock.metadata.0.name
  wait      = true
  timeout   = 600
  name      = "cloudblock"
  chart     = "./charts/cloudblock"
  set {
    name = "efs.fsid"
    value = aws_efs_file_system.aws-efs-fs.id
    type = "string"
  }
}
