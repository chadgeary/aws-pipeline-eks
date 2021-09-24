resource "helm_release" "secrets-store-csi" {
  namespace  = data.kubernetes_namespace.kube-system.metadata.0.name
  wait       = true
  timeout    = 600
  name       = "secrets-store-csi-driver"
  repository = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/charts"
  chart      = "secrets-store-csi-driver"
  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

resource "kubernetes_manifest" "serviceaccount_kube_system_csi_secrets_store_provider_aws" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "csi-secrets-store-provider-aws"
      "namespace" = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_csi_secrets_store_provider_aws_cluster_role" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "name" = "csi-secrets-store-provider-aws-cluster-role"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "serviceaccounts/token",
        ]
        "verbs" = [
          "create",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "serviceaccounts",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_csi_secrets_store_provider_aws_cluster_rolebinding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = "csi-secrets-store-provider-aws-cluster-rolebinding"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "csi-secrets-store-provider-aws-cluster-role"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "csi-secrets-store-provider-aws"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "daemonset_kube_system_csi_secrets_store_provider_aws" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "DaemonSet"
    "metadata" = {
      "labels" = {
        "app" = "csi-secrets-store-provider-aws"
      }
      "name"      = "csi-secrets-store-provider-aws"
      "namespace" = "kube-system"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "csi-secrets-store-provider-aws"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "csi-secrets-store-provider-aws"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--provider-volume=/etc/kubernetes/secrets-store-csi-providers",
              ]
              "image"           = "public.ecr.aws/aws-secrets-manager/secrets-store-csi-driver-provider-aws:${var.aws_secrets_store_provider_image_version}"
              "imagePullPolicy" = "Always"
              "name"            = "provider-aws-installer"
              "resources" = {
                "limits" = {
                  "cpu"    = "50m"
                  "memory" = "100Mi"
                }
                "requests" = {
                  "cpu"    = "50m"
                  "memory" = "100Mi"
                }
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/kubernetes/secrets-store-csi-providers"
                  "name"      = "providervol"
                },
                {
                  "mountPath"        = "/var/lib/kubelet/pods"
                  "mountPropagation" = "HostToContainer"
                  "name"             = "mountpoint-dir"
                },
              ]
            },
          ]
          "hostNetwork" = true
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "serviceAccountName" = "csi-secrets-store-provider-aws"
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/etc/kubernetes/secrets-store-csi-providers"
              }
              "name" = "providervol"
            },
            {
              "hostPath" = {
                "path" = "/var/lib/kubelet/pods"
                "type" = "DirectoryOrCreate"
              }
              "name" = "mountpoint-dir"
            },
          ]
        }
      }
      "updateStrategy" = {
        "type" = "RollingUpdate"
      }
    }
  }
}
