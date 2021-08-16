resource "aws_kms_key" "aws-kmscmk-eks" {
  description              = "KMS CMK for EKS"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.aws_prefix}-kmscmk-eks-${random_string.aws-suffix.result}"
  }
  policy = <<EOF
{
  "Id": "aws-kmscmk-eks",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable EKS Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.aws-eks-cluster-role.arn}"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.aws-account.account_id}",
          "kms:ViaService": "eks.${var.aws_region}.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Enable KMS Manager Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.aws-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "aws-kmscmk-eks-alias" {
  name          = "alias/${var.aws_prefix}-kmscmk-eks-${random_string.aws-suffix.result}"
  target_key_id = aws_kms_key.aws-kmscmk-eks.key_id
}
