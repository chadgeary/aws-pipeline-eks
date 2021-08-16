resource "aws_eks_cluster" "aws-eks-cluster" {
  name                      = "${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}"
  role_arn                  = aws_iam_role.aws-eks-cluster-role.arn
  enabled_cluster_log_types = ["api", "audit"]
  encryption_config {
    provider {
      key_arn = aws_kms_key.aws-kmscmk-eks.arn
    }
    resources = ["secrets"]
  }
  vpc_config {
    subnet_ids = [aws_subnet.aws-private-subnet-A.id, aws_subnet.aws-private-subnet-B.id]
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.kube_cidr
  }
  depends_on = [aws_iam_role_policy_attachment.aws-eks-cluster-policy-attach-1, aws_iam_role_policy_attachment.aws-eks-cluster-policy-attach-2, aws_cloudwatch_log_group.aws-cloudwatch-log-group-eks-cluster]
}
