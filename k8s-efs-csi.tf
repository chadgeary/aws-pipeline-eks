data "kubernetes_namespace" "kube-system" {
  metadata {
    name = "kube-system"
  }
}

resource "helm_release" "aws-efs-csi" {
  namespace  = data.kubernetes_namespace.kube-system.metadata.0.name
  wait       = true
  timeout    = 600
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  set {
    name = "controller.serviceAccount.create"
    value = "false"
  }
  set {
    name = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa2"
  }
  set {
    name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::274613629998:role/eksctl-myeks1-eks-cluster-ko47x-addon-iamser-Role1-1UOHSF3VICJ81"
    type = "string"
  }
  set {
    name = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws-eks-efs-role.arn
    type = "string"
  }
}
