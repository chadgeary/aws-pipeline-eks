data "aws_eks_cluster" "aws-eks-cluster" {
  name = aws_eks_cluster.aws-eks-cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.aws-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.aws-eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws-eks-cluster-auth.token
  config_path            = local_file.k8s-kubeconfig.filename
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.aws-eks-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.aws-eks-cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.aws-eks-cluster-auth.token
    config_path            = local_file.k8s-kubeconfig.filename
  }
}

resource "local_file" "k8s-kubeconfig" {
  sensitive_content = templatefile("kubeconfig.tpl", {
    cluster_name = aws_eks_cluster.aws-eks-cluster.name
    clusterca    = data.aws_eks_cluster.aws-eks-cluster.certificate_authority[0].data,
    endpoint     = data.aws_eks_cluster.aws-eks-cluster.endpoint,
  })
  filename = "./kubeconfig-${aws_eks_cluster.aws-eks-cluster.name}"
}
