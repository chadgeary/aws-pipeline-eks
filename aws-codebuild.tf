resource "aws_codebuild_project" "aws-codebuild" {
  name           = "${var.aws_prefix}-codebuild-${random_string.aws-suffix.result}"
  description    = "Codebuild for CodePipe to ECS"
  build_timeout  = "10"
  service_role   = aws_iam_role.aws-codebuild-role.arn
  encryption_key = aws_kms_key.aws-kmscmk-code.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  # https://github.com/hashicorp/terraform-provider-aws/issues/10195
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "true"
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.aws-account.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.aws-repo.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
  source {
    type = "CODEPIPELINE"
  }
  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.aws-s3-bucket.id}/build-log"
    }
  }
  vpc_config {
    vpc_id = aws_vpc.aws-vpc.id
    subnets = [
      aws_subnet.aws-private-subnet-A.id,
      aws_subnet.aws-private-subnet-B.id
    ]
    security_group_ids = [aws_security_group.aws-sg-private.id]
  }
  depends_on = [aws_security_group_rule.aws-sg-private-tcp-out, aws_security_group_rule.aws-sg-private-udp-out, aws_nat_gateway.aws-natgwA, aws_nat_gateway.aws-natgwB, aws_vpc_endpoint.aws-vpc-s3-endpoint, aws_iam_role_policy_attachment.aws-codebuild-policy-role-attach]
}
