resource "aws_ssm_parameter" "cloudblock_webpassword" {
  name = "/${var.aws_prefix}-cloudblock-${random_string.aws-suffix.result}/webpassword"
  type = "SecureString"
  key_id = aws_kms_key.aws-kmscmk-ssm.key_id
  value = var.cloudblock_webpassword
}
