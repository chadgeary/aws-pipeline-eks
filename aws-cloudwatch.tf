resource "aws_cloudwatch_log_group" "aws-cloudwatch-log-group-eks-cluster" {
  name              = "/aws/eks/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.aws-kms-cw.arn
  tags = {
    Name = "/aws/eks/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}/cluster"
  }
}

resource "aws_cloudwatch_log_group" "aws-cloudwatch-log-group-eks-nodes" {
  name              = "/aws/eks/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}/nodes"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.aws-kms-cw.arn
  tags = {
    Name = "/aws/eks/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}/nodes"
  }
}
