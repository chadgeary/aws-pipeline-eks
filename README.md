# Overview
Terraform full stack CodePipe with EKS in AWS with self-managed EKS nodes, e.g. CMK KMS encrypted, SSM managed, Cloudwatch Agent.

- Dockerfile and buildspec.yml define the container
- CodePipe fetches via S3 and passes to CodeBuild
- CodeBuild creates the container image and pushes to ECR (Container Repository)

# Features
- Encrypted (transit/rest) file store via AWS efs-csi-controller for dynamic APs
- Encrypted (transit/rest) environment vars via secrets-store-csi-driver + aws provider for SSM parameters

- TODO:
  - EKS pulls ECR and runs
  - Cognito as an IDP for OIDC.

# Instructions
```
# Edit variables
# ensure aws_* and kms_* vars are set
# ensure *_cidr vars do not overlap existing subnets
# minimum_node_count must be 2 for AWS EFS to be happy, keep Interface/IPs per instance type in mind too.
vi aws.tfvars

# Initialize terraform
terraform init

# Plan sanity check
terraform plan --var-file="aws.tfvars"

# Apply
terraform apply --var-file="aws.tfvars"
```

# Dirs
- charts/ contains local charts deployed via one of k8s-*.tf (currently only k8s-cloudblock.tf)
- code-archive/ contains a rudimentary Dockerfile / buildspec.yml for CodeBuild to create+publish a container
- playbook/ is an ansible playbook run on the EKS nodes (via AWS SSM) - mostly just configures cloudwatch metric publishing at this moment

# Helm / Charts
- k8s-aws-efs-csi.tf is the AWS-maintained EFS driver
- k8s-secrets-store.tf is the K8sSIG-maintained secrets driver + AWS-maintained provider/daemonset
- k8s-kubeapps.tf is the bitnami-maintained kubeapps
- k8s-metrics.tf is the bitnami-maintained metrics server
- k8s-charts-cloudblock.tf is self-maintained in charts/cloudblock/, a proof of concept/tooling around for the other charts. Function-wise, it'll probably mirror https://github.com/chadgeary/cloudblock
