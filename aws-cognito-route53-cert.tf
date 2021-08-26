data "aws_route53_zone" "cognito-up-top-zone" {
  name = var.domain
}

resource "aws_route53_zone" "cognito-up-sub-zone" {
  name = "${var.aws_prefix}-${random_string.aws-suffix.result}.${var.domain}"
  tags = {
    Name = "${var.aws_prefix}-cognito-up-sub-zone-${random_string.aws-suffix.result}"
  }
  depends_on = [data.aws_route53_zone.cognito-up-top-zone]
}

resource "aws_route53_record" "cognito-up-ns-record" {
  zone_id = data.aws_route53_zone.cognito-up-top-zone.zone_id
  name    = "${var.aws_prefix}-${random_string.aws-suffix.result}.${var.domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.cognito-up-sub-zone.name_servers
}

resource "aws_route53_record" "cognito-up-root-record" {
  count   = var.create_root_a_record ? 1 : 0
  zone_id = data.aws_route53_zone.cognito-up-top-zone.zone_id
  name    = var.domain
  type    = "A"
  ttl     = "300"
  records = ["127.0.0.1"]
}

resource "aws_route53_record" "cognito-alias-record" {
  zone_id         = aws_route53_zone.cognito-up-sub-zone.zone_id
  name            = "${var.aws_prefix}-${random_string.aws-suffix.result}.${var.domain}"
  type            = "A"
  allow_overwrite = true
  alias {
    name                   = aws_cognito_user_pool_domain.cognito-up-domain.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cognito-up-cert" {
  provider          = aws.aws-us-east-1
  domain_name       = "${var.aws_prefix}-${random_string.aws-suffix.result}.${var.domain}"
  validation_method = "DNS"
  tags = {
    Name = "${var.aws_prefix}-cognito-up-cert-${random_string.aws-suffix.result}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cognito-up-a-record" {
  name    = aws_cognito_user_pool_domain.cognito-up-domain.domain
  type    = "A"
  zone_id = data.aws_route53_zone.cognito-up-top-zone.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.cognito-up-domain.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2"
  }
}

resource "aws_route53_record" "cognito-up-cert-record" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cognito-up-cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cognito-up-cert.domain_validation_options)[0].resource_record_value]
  ttl             = 60
  type            = tolist(aws_acm_certificate.cognito-up-cert.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.cognito-up-sub-zone.zone_id
}

resource "aws_acm_certificate_validation" "cognito-up-cert-validation" {
  provider                = aws.aws-us-east-1
  certificate_arn         = aws_acm_certificate.cognito-up-cert.arn
  validation_record_fqdns = [aws_route53_record.cognito-up-cert-record.fqdn]
}
