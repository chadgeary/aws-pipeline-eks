resource "aws_s3_bucket" "aws-s3-bucket" {
  bucket = "${var.aws_prefix}-bucket-${random_string.aws-suffix.result}"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.aws-kmscmk-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  force_destroy = true
  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KMS Manager",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${data.aws_iam_user.aws-kmsmanager.arn}"]
      },
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}",
        "arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}/*"
      ]
    },
    {
      "Sid": "Codepipe",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.aws-codepipe-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL"
      ],
      "Resource": ["arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}","arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}/*"]
    },
    {
      "Sid": "Codebuild",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.aws-codebuild-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL"
      ],
      "Resource": ["arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}","arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}/*"]
    },
    {
      "Sid": "EKSNodes",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.aws-eks-node-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL",
        "s3:ListBucket"
      ],
      "Resource": ["arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}","arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}/playbook","arn:${data.aws_partition.aws-partition.partition}:s3:::${var.aws_prefix}-bucket-${random_string.aws-suffix.result}/ssm"]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "aws-s3-bucket-pub-access" {
  bucket                  = aws_s3_bucket.aws-s3-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "aws-s3-bucket-archive-object" {
  bucket         = aws_s3_bucket.aws-s3-bucket.id
  key            = "code-archive.zip"
  content_base64 = filebase64(data.archive_file.aws-code-archive.output_path)
  kms_key_id     = aws_kms_key.aws-kmscmk-s3.arn
}

resource "aws_s3_bucket_object" "aws-s3-bucket-playbook-files" {
  for_each       = fileset("playbook/", "**")
  bucket         = aws_s3_bucket.aws-s3-bucket.id
  key            = "playbook/${each.value}"
  content_base64 = base64encode(file("${path.module}/playbook/${each.value}"))
  kms_key_id     = aws_kms_key.aws-kmscmk-s3.arn
}
