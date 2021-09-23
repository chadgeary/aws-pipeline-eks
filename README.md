# Overview
Terraform full stack CodePipe with EKS in AWS with self-managed EKS nodes, e.g. CMK KMS encrypted, SSM managed, Cloudwatch Agent.

- Dockerfile and buildspec.yml define the container
- CodePipe fetches via S3 and passes to CodeBuild
- CodeBuild creates the container image and pushes to ECR (Container Repository)

- TODO:
  - EKS pulls ECR and runs
  - EFS via IRSA for dynamic EFS APs.
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

# Charts
- k8s-kubeapps.tf is the bitnami published kubeapps chart
- k8s-efs-csi.tf is the aws published EFS driver chart
- k8s-metrics.tf is the bitnami published metrics server chart
- k8s-cloudblock.tf is the local chart in charts/cloudblock/ which is a proof of concept/tooling around for EFS. It'll probably mirror https://github.com/chadgeary/cloudblock
