data "aws_iam_policy" "aws-eks-cluster-policy-general" {
  arn = "arn:${data.aws_partition.aws-partition.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy" "aws-eks-cluster-policy-kms" {
  name   = "${var.aws_prefix}-eks-cluster-policy-kms-${random_string.aws-suffix.result}"
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "CloudwatchEKSKMS",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.aws-kmscmk-code.arn}","${aws_kms_key.aws-kmscmk-eks.arn}","${aws_kms_key.aws-kmscmk-ec2.arn}"]
    },
    {
      "Sid": "EKSDecryptKMS",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": ["${aws_kms_key.aws-kmscmk-eks.arn}","${aws_kms_key.aws-kmscmk-ec2.arn}"]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy" "aws-eks-cluster-policy-config" {
  name   = "${var.aws_prefix}-eks-cluster-policy-config-${random_string.aws-suffix.result}"
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "Config",
      "Effect": "Allow",
      "Action": [
        "eks:AssociateIdentityProviderConfig"
      ],
      "Resource": ["arn:${data.aws_partition.aws-partition.partition}:eks:${var.aws_region}:${data.aws_caller_identity.aws-account.account_id}:cluster/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}"]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "aws-eks-cluster-role" {
  name               = "${var.aws_prefix}-eks-cluster-role-${random_string.aws-suffix.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKS",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["eks.amazonaws.com"]
      }
    },
    {
      "Sid": "Manager",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": ["${data.aws_iam_user.aws-kmsmanager.arn}"]
      }
    },
    {
      "Sid": "Account",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": ["${data.aws_caller_identity.aws-account.account_id}"]
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-policy-attach-1" {
  role       = aws_iam_role.aws-eks-cluster-role.name
  policy_arn = data.aws_iam_policy.aws-eks-cluster-policy-general.arn
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-policy-attach-2" {
  role       = aws_iam_role.aws-eks-cluster-role.name
  policy_arn = aws_iam_policy.aws-eks-cluster-policy-kms.arn
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-policy-attach-3" {
  role       = aws_iam_role.aws-eks-cluster-role.name
  policy_arn = aws_iam_policy.aws-eks-cluster-policy-config.arn
}
