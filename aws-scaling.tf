# tags for scaling ec2s 
locals {
  asg-tags = [
    {
      key   = "Name"
      value = "worker.${var.aws_prefix}${random_string.aws-suffix.result}.internal"
    },
    {
      key   = "Cluster"
      value = "${var.aws_prefix}${random_string.aws-suffix.result}"
    }
  ]
}

# instance ssh key
resource "aws_key_pair" "aws-instance-key" {
  key_name   = "${var.aws_prefix}-instance-key-${random_string.aws-suffix.result}"
  public_key = var.instance_key
  tags = {
    Name = "${var.aws_prefix}-instance-key-${random_string.aws-suffix.result}"
  }
}

# template for node group
resource "aws_launch_template" "aws-launch-template" {
  name_prefix            = "${var.aws_prefix}-launch-template-${random_string.aws-suffix.result}"
  vpc_security_group_ids = [aws_security_group.aws-sg-private.id, aws_eks_cluster.aws-eks-cluster.vpc_config[0].cluster_security_group_id]
  ebs_optimized          = true
  image_id               = aws_ami_copy.ami-with-cmk.id
  key_name               = aws_key_pair.aws-instance-key.key_name
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.instance_vol_gb
      volume_type = var.instance_vol_type
    }
  }
  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==SCRIPT=="

--==SCRIPT==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
/etc/eks/bootstrap.sh ${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}

--==SCRIPT==--\
  EOF
  )
}

# node group
resource "aws_eks_node_group" "aws-eks-node-group" {
  cluster_name           = aws_eks_cluster.aws-eks-cluster.name
  node_group_name_prefix = "${var.aws_prefix}-node-group-${random_string.aws-suffix.result}"
  node_role_arn          = aws_iam_role.aws-eks-node-role.arn
  subnet_ids             = [aws_subnet.aws-private-subnet-A.id, aws_subnet.aws-private-subnet-B.id]
  scaling_config {
    desired_size = var.minimum_node_count
    min_size     = var.minimum_node_count
    max_size     = var.maximum_node_count
  }
  ami_type = "CUSTOM"
  launch_template {
    id      = aws_launch_template.aws-launch-template.id
    version = aws_launch_template.aws-launch-template.latest_version
  }
  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types
  depends_on     = [aws_iam_role_policy_attachment.aws-eks-node-policy-attach-1, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-2, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-3, aws_iam_role_policy_attachment.aws-eks-node-policy-attach-4]
}
