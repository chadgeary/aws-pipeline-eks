---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${ cluster_name }
  region: ${ cluster_region }

identityProviders:
  - name: ${ cognito_name }
    type: oidc
    issuerUrl: ${ cognito_url }
    clientId: ${ cognito_client_id }
    usernameClaim: "cognito:username"
    usernamePrefix: "oidc:"
    groupsClaim: "cognito:groups"
    groupsPrefix: "oidc:"
