resource "aws_efs_file_system" "aws-efs-fs" {
  creation_token = "${var.aws_prefix}-efs-${random_string.aws-suffix.result}"
  encrypted = "true"
  kms_key_id = aws_kms_key.aws-kmscmk-efs.arn
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

resource "aws_efs_file_system_policy" "aws-efs-policy" {
  file_system_id = aws_efs_file_system.aws-efs-fs.id
  bypass_policy_lockout_safety_check = "false"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "EKSEFS",
    "Statement": [
        {
            "Sid": "EKSEFS",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.aws-efs-fs.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "aws-efs-mntA" {
  file_system_id = aws_efs_file_system.aws-efs-fs.id
  subnet_id = aws_subnet.aws-public-subnet-A.id
  security_groups = [aws_security_group.aws-sg-private.id]
}

resource "aws_efs_mount_target" "aws-efs-mntB" {
  file_system_id = aws_efs_file_system.aws-efs-fs.id
  subnet_id = aws_subnet.aws-public-subnet-B.id
  security_groups = [aws_security_group.aws-sg-private.id]
}
