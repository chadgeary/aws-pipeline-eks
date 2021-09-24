provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "aws-us-east-1"
  region  = "us-east-1"
  profile = var.aws_profile
}

variable "aws_prefix" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "domain" {
  type = string
}

variable "create_root_a_record" {
  type = bool
}

variable "kms_manager" {
  type        = string
  description = "An IAM user for management of KMS key"
}

data "aws_caller_identity" "aws-account" {
}

data "aws_partition" "aws-partition" {
}

data "aws_iam_user" "aws-kmsmanager" {
  user_name = var.kms_manager
}

data "aws_availability_zones" "aws-azs" {
  state = "available"
}

variable "aws_az" {
  type    = number
  default = 0
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_A_cidr" {
  type = string
}

variable "public_subnet_B_cidr" {
  type = string
}

variable "private_subnet_A_cidr" {
  type = string
}

variable "private_subnet_B_cidr" {
  type = string
}

variable "kube_cidr" {
  type = string
}

resource "random_string" "aws-suffix" {
  length  = 5
  upper   = false
  special = false
}

variable "service_port" {
  type = number
}

variable "service_protocol" {
  type = string
}

variable "client_cidrs" {
  type        = list(any)
  description = "List of subnets (in CIDR notation) granted load balancer port and protocol ingress"
  default     = []
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "vendor_ami_account_number" {
  type = string
}

variable "vendor_ami_name_string" {
  type = string
}

variable "instance_vol_gb" {
  type = number
}

variable "instance_vol_type" {
  type = string
}

variable "instance_types" {
  type = list(any)
}

variable "minimum_node_count" {
  type = number
}

variable "maximum_node_count" {
  type = number
}

variable "instance_key" {
  type = string
}

variable "cloudblock_webpassword" {
  type = string
}
