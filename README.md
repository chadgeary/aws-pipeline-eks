# Overview
Terraform full stack CodePipe with EKS in AWS with self-managed EKS nodes, e.g. CMK KMS encrypted, SSM managed, Cloudwatch Agent.

- Dockerfile and buildspec.yml define the container
- CodePipe fetches via S3 and passes to CodeBuild
- CodeBuild creates the container image and pushes to ECR (Container Repository)
- TODO: EKS pulls ECR and runs.
