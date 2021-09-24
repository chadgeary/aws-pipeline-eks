resource "aws_eks_cluster" "aws-eks-cluster" {
  name                      = "${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}"
  role_arn                  = aws_iam_role.aws-eks-cluster-role.arn
  enabled_cluster_log_types = ["api", "audit"]
  encryption_config {
    provider {
      key_arn = aws_kms_key.aws-kmscmk-eks.arn
    }
    resources = ["secrets"]
  }
  vpc_config {
    subnet_ids              = [aws_subnet.aws-private-subnet-A.id, aws_subnet.aws-private-subnet-B.id]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.kube_cidr
  }
  depends_on = [aws_iam_role_policy_attachment.aws-eks-cluster-policy-attach-1, aws_iam_role_policy_attachment.aws-eks-cluster-policy-attach-2, aws_iam_role_policy_attachment.aws-eks-cluster-policy-attach-3, aws_iam_role_policy_attachment.aws-eks-cluster-policy-attach-4, aws_cloudwatch_log_group.aws-cloudwatch-log-group-eks-cluster]
}

# Nodes assume IAM role
data "tls_certificate" "aws-eks-certificate" {
  url = aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "aws-oidc-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.aws-eks-certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.aws-eks-cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "aws-eks-cluster-auth" {
  name = "${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}"
}

data "aws_iam_policy_document" "aws-eks-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.aws-oidc-provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.aws-oidc-provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws-eks-role-nodes" {
  assume_role_policy = data.aws_iam_policy_document.aws-eks-role-policy.json
  name               = "${var.aws_prefix}-eks-nodes-role-${random_string.aws-suffix.result}"
}

# Users via Cognito
#resource "aws_eks_identity_provider_config" "cognito-up-identity" {
#  cluster_name = aws_eks_cluster.aws-eks-cluster.name
#  oidc {
#    client_id                     = aws_cognito_user_pool_client.cognito-up-client.id
#    identity_provider_config_name = aws_cognito_identity_pool.cognito-ip.identity_pool_name
#    issuer_url                    = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool_client.cognito-up-client.user_pool_id}"
#    groups_claim                  = "cognito:groups"
#    groups_prefix                 = "oidc:"
#    username_claim                = "cognito:username"
#    username_prefix               = "oidc:"
#  }
#}

# kubeconfig
resource "local_file" "k8s-kubeconfig" {
  sensitive_content = templatefile("./templates/aws-eks-kubeconfig.tpl", {
    cluster_name     = aws_eks_cluster.aws-eks-cluster.name,
    cluster_ca       = data.aws_eks_cluster.aws-eks-cluster.certificate_authority[0].data,
    cluster_endpoint = data.aws_eks_cluster.aws-eks-cluster.endpoint,
    cluster_arn      = aws_eks_cluster.aws-eks-cluster.arn,
    cluster_region   = var.aws_region
    aws_profile      = var.aws_profile
  })
  filename        = "./kubeconfig-${var.aws_prefix}-${random_string.aws-suffix.result}"
  file_permission = "0600"
}

data "aws_eks_cluster" "aws-eks-cluster" {
  name = aws_eks_cluster.aws-eks-cluster.name
}

# idp via eksctl
resource "local_file" "k8s-idp" {
  sensitive_content = templatefile("./templates/aws-eks-idp.tpl", {
    cluster_name      = aws_eks_cluster.aws-eks-cluster.name,
    cluster_region    = var.aws_region
    cognito_name      = aws_cognito_identity_pool.cognito-ip.identity_pool_name
    cognito_url       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool_client.cognito-up-client.user_pool_id}"
    cognito_client_id = aws_cognito_user_pool_client.cognito-up-client.id
  })
  filename        = "./idp-${var.aws_prefix}-${random_string.aws-suffix.result}"
  file_permission = "0600"
}
