resource "aws_cognito_user_pool" "cognito-up" {
  name              = "${var.aws_prefix}-user-pool-${random_string.aws-suffix.result}"
  mfa_configuration = "ON"
  software_token_mfa_configuration {
    enabled = true
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  password_policy {
    minimum_length                   = 8
    require_lowercase                = "true"
    require_uppercase                = "true"
    require_numbers                  = "true"
    require_symbols                  = "true"
    temporary_password_validity_days = 1
  }
  tags = {
    Name = "${var.aws_prefix}-cognito-up-${random_string.aws-suffix.result}"
  }
}

resource "aws_cognito_user_pool_domain" "cognito-up-domain" {
  domain          = "${var.aws_prefix}-${random_string.aws-suffix.result}.${var.domain}"
  certificate_arn = aws_acm_certificate.cognito-up-cert.arn
  user_pool_id    = aws_cognito_user_pool.cognito-up.id
  depends_on      = [aws_acm_certificate_validation.cognito-up-cert-validation]
}

resource "aws_cognito_user_pool_client" "cognito-up-client" {
  name            = "${var.aws_prefix}-user-pool-client-${random_string.aws-suffix.result}"
  user_pool_id    = aws_cognito_user_pool.cognito-up.id
  generate_secret = true
}

resource "aws_cognito_identity_pool" "cognito-ip" {
  identity_pool_name               = "${var.aws_prefix}-id-pool-${random_string.aws-suffix.result}"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito-up-client.id
    provider_name           = aws_cognito_user_pool.cognito-up.endpoint
    server_side_token_check = false
  }
}
