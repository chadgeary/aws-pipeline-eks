resource "kubernetes_namespace" "cloudblock" {
  metadata {
    name = "cloudblock"
  }
}

resource "local_file" "cloudblock-secrets" {
  sensitive_content = templatefile("./templates/cloudblock-secrets.tpl", {
    aws_prefix      = var.aws_prefix,
    aws_suffix      = random_string.aws-suffix.result
  })
  filename        = "./charts/cloudblock/templates/secrets.yaml"
  file_permission = "0600"
}

resource "helm_release" "cloudblock" {
  namespace = kubernetes_namespace.cloudblock.metadata.0.name
  wait      = true
  timeout   = 600
  name      = "cloudblock"
  chart     = "./charts/cloudblock"
  set {
    name  = "efs.fsid"
    value = aws_efs_file_system.aws-efs-fs.id
    type  = "string"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws-k8s-cloudblock-role.arn
    type  = "string"
  }
  depends_on = [local_file.cloudblock-secrets, aws_ssm_parameter.cloudblock_webpassword]
}
