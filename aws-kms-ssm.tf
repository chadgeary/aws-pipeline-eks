resource "aws_kms_key" "aws-kmscmk-ssm" {
  description              = "KMS CMK for SSM"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.aws_prefix}-kmscmk-ssm-${random_string.aws-suffix.result}"
  }
  policy = <<EOF
{
  "Id": "aws-kmscmk-ssm",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable cloudblock Decrypt via SSM",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.aws-k8s-cloudblock-role.arn}"
      },
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.aws-account.account_id}",
          "kms:ViaService": "ssm.${var.aws_region}.amazonaws.com"
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

resource "aws_kms_alias" "aws-kmscmk-ssm-alias" {
  name          = "alias/${var.aws_prefix}-kmscmk-ssm-${random_string.aws-suffix.result}"
  target_key_id = aws_kms_key.aws-kmscmk-ssm.key_id
}
