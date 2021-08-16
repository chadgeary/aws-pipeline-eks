# Region to create/deploy resources
aws_region = "us-east-2"

# A prefix to various components' names
# Note: a random suffix is generated
# e.g. 'dev1-eks-cluster-abc123'
aws_prefix = "dev1"

# The credentials profile to use (e.g. ~/.aws/credentials), generally default
aws_profile = "default"

# A non-root IAM user for managing/owning KMS keys
kms_manager = "chad_geary"

# networking
vpc_cidr     = "10.10.20.0/22"
public_subnet_A_cidr = "10.10.20.0/24"
public_subnet_B_cidr = "10.10.21.0/24"
private_subnet_A_cidr = "10.10.22.0/24"
private_subnet_B_cidr = "10.10.23.0/24"
kube_cidr = "10.10.24.0/22"

# service - exposed via NLB
service_port     = 53
service_protocol = "TCP"

# service clients - able to reach NLB
client_cidrs = ["0.0.0.0/0"]

# cloudwatch log retention
log_retention_days = 30

# ami must be an amazon eks AMI
vendor_ami_account_number = "602401143452"
vendor_ami_name_string = "amazon-eks-node-1.20-v*"

# instance details
instance_types = ["t3a.medium", "t3.medium"]
instance_vol_gb = "50"
instance_vol_type = "gp3"
instance_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu1gya2wMLeo1rBJFcb6ZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6RSAltLROUONn0SF2BvvJUueqxpAIaA2rU4MSI69P"
minimum_node_count = 2
maximum_node_count = 2
