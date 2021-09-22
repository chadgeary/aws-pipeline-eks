resource "aws_iam_policy" "aws-eks-efs-policy-efs" {
  name   = "${var.aws_prefix}-eks-efs-policy-efs-${random_string.aws-suffix.result}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "aws-eks-efs-role" {
  name               = "${var.aws_prefix}-eks-efs-role-${random_string.aws-suffix.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSEFS",
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": ["arn:${data.aws_partition.aws-partition.partition}:iam::${data.aws_caller_identity.aws-account.account_id}:oidc-provider/${substr(data.aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer, 8, -1)}"]
      },
      "Condition": {
        "StringEquals": {
          "${substr(data.aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer, 8, -1)}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa",
          "${substr(data.aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer, 8, -1)}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws-eks-efs-policy-attach-1" {
  role       = aws_iam_role.aws-eks-efs-role.name
  policy_arn = aws_iam_policy.aws-eks-efs-policy-efs.arn
}
