# policy and role for service account to get+decrypt SSM parameters matching ${var.aws_prefix}-cloudblock-${random_string.aws-suffix.result}/*
resource "aws_iam_policy" "aws-k8s-cloudblock-policy" {
  name   = "${var.aws_prefix}-k8s-cloudblock-policy-${random_string.aws-suffix.result}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "arn:${data.aws_partition.aws-partition.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.aws-account.account_id}:parameter/${var.aws_prefix}-cloudblock-${random_string.aws-suffix.result}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "${aws_kms_key.aws-kmscmk-ssm.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "aws-k8s-cloudblock-role" {
  name               = "${var.aws_prefix}-k8s-cloudblock-role-${random_string.aws-suffix.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSSSM",
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": ["arn:${data.aws_partition.aws-partition.partition}:iam::${data.aws_caller_identity.aws-account.account_id}:oidc-provider/${substr(data.aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer, 8, -1)}"]
      },
      "Condition": {
        "StringEquals": {
          "${substr(data.aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer, 8, -1)}:sub": "system:serviceaccount:cloudblock:cloudblock",
          "${substr(data.aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer, 8, -1)}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws-k8s-cloudblock-policy-attach-1" {
  role       = aws_iam_role.aws-k8s-cloudblock-role.name
  policy_arn = aws_iam_policy.aws-k8s-cloudblock-policy.arn
}
