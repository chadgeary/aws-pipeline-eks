output "aws-output" {
  value = <<OUTPUT
# Code Pipeline
https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.aws_prefix}-codepipe-${random_string.aws-suffix.result}/view?region=${var.aws_region}

# Using kubectl or helm, reference the output config, e.g.:
kubectl --kubeconfig kubeconfig-${var.aws_prefix}-${random_string.aws-suffix.result} port-forward --namespace kubeapps svc/kubeapps :80
helm --kubeconfig kubeconfig-${var.aws_prefix}-${random_string.aws-suffix.result} --namespace kube-system get pods

# List EC2 instances running as EKS nodes
AWS_PROFILE=${var.aws_profile} aws ec2 describe-instances --region ${var.aws_region} --query 'Reservations[].Instances[*].[InstanceId]' --filters Name=tag:eks:cluster-name,Values=${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result} Name=instance-state-name,Values=running --output text
OUTPUT
}
