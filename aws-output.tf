output "aws-output" {
  value = <<OUTPUT
Code Pipeline: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.aws_prefix}-codepipe-${random_string.aws-suffix.result}/view?region=${var.aws_region}
OUTPUT
}
