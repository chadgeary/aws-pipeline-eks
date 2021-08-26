resource "aws_kms_key" "aws-kmscmk-ec2" {
  description              = "Key for ph ec2/ebs"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "aws-kmscmk-ec2"
  }
  policy = <<EOF
{
  "Id": "AMIEC2",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.aws-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.aws-eks-node-role.arn}"
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Sid": "Allow access through EKS Autoscaling",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:${data.aws_partition.aws-partition.partition}:iam::${data.aws_caller_identity.aws-account.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow access through EKS Autoscaling 2",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:${data.aws_partition.aws-partition.partition}:iam::${data.aws_caller_identity.aws-account.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      },
      "Action": "kms:CreateGrant",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "aws-kmscmk-ec2-alias" {
  name          = "alias/aws-kmscmk-ec2"
  target_key_id = aws_kms_key.aws-kmscmk-ec2.key_id
}
