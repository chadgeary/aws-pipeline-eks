resource "aws_kms_key" "aws-kms-cw" {
  description              = "KMS CMK for Cloudwatch"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.aws_prefix}-kms-cw-${random_string.aws-suffix.result}"
  }
  policy = <<EOF
{
  "Id": "aws-kms-cw",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable KMS Manager Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.aws-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access through cloudwatch",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
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
        "ArnEquals": {
          "kms:EncryptionContext:aws:logs:arn": ["arn:${data.aws_partition.aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.aws-account.account_id}:log-group:/aws/eks/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}/cluster","arn:${data.aws_partition.aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.aws-account.account_id}:log-group:/aws/eks/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}/nodes"]
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "aws-kms-cw-alias" {
  name          = "alias/${var.aws_prefix}-kms-cw-${random_string.aws-suffix.result}"
  target_key_id = aws_kms_key.aws-kms-cw.key_id
}
