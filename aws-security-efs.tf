resource "aws_security_group" "aws-sg-efs" {
  name        = "${var.aws_prefix}-sg-efs-${random_string.aws-suffix.result}"
  description = "Security group for efs"
  vpc_id      = aws_vpc.aws-vpc.id
  tags = {
    Name = "${var.aws_prefix}-sg-efs-${random_string.aws-suffix.result}"
  }
}

resource "aws_security_group_rule" "aws-sg-efs-service-public" {
  security_group_id        = aws_security_group.aws-sg-efs.id
  type                     = "ingress"
  description              = "IN FROM PRIVATE"
  from_port                = "2049"
  to_port                  = "2049"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.aws-sg-private.id
}
