apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${ cluster_ca } 
    server: ${ cluster_endpoint }
  name: ${ cluster_arn }
contexts:
- context:
    cluster: ${ cluster_arn }
    user: ${ cluster_arn }
  name: ${ cluster_arn }
current-context: ${ cluster_arn }
kind: Config
preferences: {}
users:
- name: ${ cluster_arn }
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - ${ cluster_region }
      - eks
      - get-token
      - --cluster-name
      - ${ cluster_name }
      command: aws
