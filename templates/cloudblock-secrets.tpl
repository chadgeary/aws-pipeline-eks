apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: cloudblock-secrets
spec:
  provider: aws
  secretObjects:
    - secretName: webpassword
      type: Opaque
      labels:
        provider: "csi-driver"
      data:
      - objectName: webpassword
        key: webpassword
  parameters:
    objects: |
        - objectName: "/${aws_prefix}-cloudblock-${aws_suffix}/webpassword"
          objectType: "ssmparameter"
          objectAlias: "webpassword"
