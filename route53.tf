#
# Domain and SSL Certificate for public S3 web resource.
#

resource "aws_acm_certificate" "web" {
  domain_name       = var.target_hostname
  validation_method = "DNS"

  # Cloudfront certificates have to be in the US (Virginia) region
  provider = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}

# Wait until certificate is provisioned
resource "aws_acm_certificate_validation" "web" {
  certificate_arn         = aws_acm_certificate.web.arn
  validation_record_fqdns = [for record in aws_route53_record.web : record.fqdn]

  # Cloudfront certificates have to be in the US (Virginia) region
  provider = aws.virginia
}

#  Create DNS domain for certificate dns validation
resource "aws_route53_record" "web" {
  for_each = {
    for dvo in aws_acm_certificate.web.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id

  provider = aws.main
}

# Link CloudFront with route53
resource "aws_route53_record" "cloudfront_web_basic_authentication" {
  count = length(var.authentication) > 0 ? 1 : 0

  zone_id = var.zone_id
  name    = var.target_hostname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_basic_authentication.0.domain_name
    zone_id                = aws_cloudfront_distribution.web_basic_authentication.0.hosted_zone_id
    evaluate_target_health = false
  }

  provider = aws.main
}

resource "aws_route53_record" "cloudfront_web" {
  count = length(var.authentication) > 0 ? 0 : 1

  zone_id = var.zone_id
  name    = var.target_hostname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web.0.domain_name
    zone_id                = aws_cloudfront_distribution.web.0.hosted_zone_id
    evaluate_target_health = false
  }

  provider = aws.main
}
