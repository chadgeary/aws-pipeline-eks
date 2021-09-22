provider "kubernetes" {
  config_path = local_file.k8s-kubeconfig.filename
}

provider "helm" {
  kubernetes {
    config_path = local_file.k8s-kubeconfig.filename
  }
}
