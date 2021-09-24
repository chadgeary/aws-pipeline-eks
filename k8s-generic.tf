provider "kubernetes" {
  config_path = local_file.k8s-kubeconfig.filename
  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    config_path = local_file.k8s-kubeconfig.filename
  }
}

data "kubernetes_namespace" "kube-system" {
  metadata {
    name = "kube-system"
  }
}

variable "aws_secrets_store_provider_image_version" {
  type    = string
  default = "1.0.r2-2021.08.13.20.34-linux-amd64"
}
