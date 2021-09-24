# Region to create/deploy resources
aws_region = "us-east-1"

# A label prefixed to various components' names
# A unique suffix is randomly generated
# e.g. 'myeks1-lambdafunction-12345'
aws_prefix = "cluster1"

# The AWSCLI profile to use, generally default
aws_profile = "default"

# A non-root IAM user for managing/owning KMS keys
kms_manager = "my_aws_username"

# web password
cloudblock_webpassword = "Please change me!"

# Route53 domain if no A record exist for the domain, please set create_root_a_record to true
domain               = "example.com"
create_root_a_record = true

# networking
vpc_cidr              = "10.10.20.0/22"
public_subnet_A_cidr  = "10.10.20.0/24"
public_subnet_B_cidr  = "10.10.21.0/24"
private_subnet_A_cidr = "10.10.22.0/24"
private_subnet_B_cidr = "10.10.23.0/24"
kube_cidr             = "10.10.24.0/22"

# service
service_port     = 51820
service_protocol = "UDP"

# service clients
client_cidrs = ["0.0.0.0/0"]

# logs
log_retention_days = 30

# ami
vendor_ami_account_number = "602401143452"
vendor_ami_name_string    = "amazon-eks-node-1.20-v*"

# The link-referenced image version run via DaemonSet that integrates AWS with Kubernetes' secrets-store-csi-driver, a.k.a "secrets-store-csi-driver-provider"
# see: https://github.com/aws/secrets-store-csi-driver-provider-aws/blob/main/deployment/aws-provider-installer.yaml#L61
aws_secrets_store_provider_image_version = "1.0.r2-2021.08.13.20.34-linux-amd64"

# instances - keep in mind IP addressing limits per instance type (see below table)
instance_types     = ["t3a.medium"]
instance_vol_gb    = "20"
instance_vol_type  = "gp3"
instance_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu1gya2wMLeo1rBJFcb6ZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6RSAltLROUONn0SF2BvvJUueqxpAIaA2rU4MSI69P"
minimum_node_count = 2
maximum_node_count = 2

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI
# Common instance types - see URL for full list. Note t3.small 3x4 vs t3a.small 2x4
# Instance           MaxInterfaces * PrivateIPv4perInterface
# t3.nano            2                2
# t3.micro           2                2
# t3.small           3                4
# t3.medium          3                6
# t3.large           3               12
# t3.xlarge          4               15
# t3.2xlarge         4               15
# t3a.nano           2                2
# t3a.micro          2                2
# t3a.small          2                4
# t3a.medium         3                6
# t3a.large          3               12
# t3a.xlarge         4               15
# t3a.2xlarge        4               15
