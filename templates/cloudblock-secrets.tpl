apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: cloudblock-secrets
spec:
  provider: aws
  secretObjects:
    - secretName: cloudblock-secrets           
      type: Opaque
      data:
      - objectName: WEBPASSWORD
        key: password
  parameters:
    objects: |
        - objectName: "/${aws_prefix}-cloudblock-${aws_suffix}/webpassword"
          objectType: "ssmparameter"
