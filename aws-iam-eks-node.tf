data "aws_iam_policy" "aws-eks-node-policy-worker" {
  arn = "arn:${data.aws_partition.aws-partition.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "aws-eks-node-policy-ecr" {
  arn = "arn:${data.aws_partition.aws-partition.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "aws-eks-node-policy-ssm" {
  arn = "arn:${data.aws_partition.aws-partition.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "aws-eks-node-policy-cni" {
  arn = "arn:${data.aws_partition.aws-partition.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy" "aws-eks-node-policy-s3kms" {
  name   = "${var.aws_prefix}-eks-node-policy-s3kms-${random_string.aws-suffix.result}"
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "CloudwatchECRS3KMS",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.aws-kms-cw.arn}","${aws_kms_key.aws-kmscmk-ecr.arn}","${aws_kms_key.aws-kmscmk-s3.arn}"]
    },
    {
      "Sid": "ECRS3DecryptKMS",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": ["${aws_kms_key.aws-kmscmk-ecr.arn}","${aws_kms_key.aws-kmscmk-s3.arn}"]
    },
    {
      "Sid": "ListObjectsinBucket",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": ["${aws_s3_bucket.aws-s3-bucket.arn}"]
    },
    {
      "Sid": "GetObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["${aws_s3_bucket.aws-s3-bucket.arn}/playbook/*"]
    },
    {
      "Sid": "PutObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": ["${aws_s3_bucket.aws-s3-bucket.arn}/ssm/*"]
    },
    {
      "Sid": "S3CMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.aws-kmscmk-s3.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "aws-eks-node-role" {
  name               = "${var.aws_prefix}-eks-node-role-${random_string.aws-suffix.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKS",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws-eks-node-policy-attach-1" {
  role       = aws_iam_role.aws-eks-node-role.name
  policy_arn = data.aws_iam_policy.aws-eks-node-policy-worker.arn
}

resource "aws_iam_role_policy_attachment" "aws-eks-node-policy-attach-2" {
  role       = aws_iam_role.aws-eks-node-role.name
  policy_arn = data.aws_iam_policy.aws-eks-node-policy-ecr.arn
}

resource "aws_iam_role_policy_attachment" "aws-eks-node-policy-attach-3" {
  role       = aws_iam_role.aws-eks-node-role.name
  policy_arn = data.aws_iam_policy.aws-eks-node-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "aws-eks-node-policy-attach-4" {
  role       = aws_iam_role.aws-eks-node-role.name
  policy_arn = data.aws_iam_policy.aws-eks-node-policy-cni.arn
}

resource "aws_iam_role_policy_attachment" "aws-eks-node-policy-attach-5" {
  role       = aws_iam_role.aws-eks-node-role.name
  policy_arn = aws_iam_policy.aws-eks-node-policy-s3kms.arn
}
