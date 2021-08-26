output "aws-output" {
  value = <<OUTPUT
# Code Pipeline
https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.aws_prefix}-codepipe-${random_string.aws-suffix.result}/view?region=${var.aws_region}

# Using kubectl, reference the output config, e.g.:
kubectl --kubeconfig kubeconfig-${random_string.aws-suffix.result}-eks-cluster-${random_string.aws-suffix.result} port-forward -n dashboard svc/dashboard-kubeapps :80

# List EC2 instances running as EKS nodes
AWS_PROFILE=${var.aws_profile} aws ec2 describe-instances --region ${var.aws_region} --query 'Reservations[].Instances[*].[InstanceId]' --filters Name=tag:eks:cluster-name,Values=${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result} Name=instance-state-name,Values=running --output text
OUTPUT
}
