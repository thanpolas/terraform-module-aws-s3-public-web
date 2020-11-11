#
# Cloudfront distribution for the web S3 bucket.
#

locals {
  s3_origin_id = "${var.target_hostname}-origin"
}

resource "aws_cloudfront_distribution" "web_basic_authentication" {
  count = length(var.authentication) > 0 ? 1 : 0

  # Wait until certificate has been provisioned
  # Wait until s3 has been provisioned
  depends_on = [
    aws_acm_certificate_validation.web,
    aws_s3_bucket.web,
  ]

  enabled             = true
  aliases             = [var.target_hostname]
  default_root_object = "index.html"
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false

  origin {
    domain_name = aws_s3_bucket.web.website_endpoint
    origin_id   = local.s3_origin_id

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 86400
    min_ttl                = 0
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.basicauth.0.qualified_arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.web.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  tags = {
    Name = "${var.name}-cloudfront"
  }

  provider = aws.main
}

resource "aws_cloudfront_distribution" "web" {
  count = length(var.authentication) > 0 ? 0 : 1

  # Wait until certificate has been provisioned
  # Wait until s3 has been provisioned
  depends_on = [
    aws_acm_certificate_validation.web,
    aws_s3_bucket.web,
  ]

  enabled             = true
  aliases             = [var.target_hostname]
  default_root_object = "index.html"
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false

  origin {
    domain_name = aws_s3_bucket.web.website_endpoint
    origin_id   = local.s3_origin_id

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 86400
    min_ttl                = 0
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.web.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  tags = {
    Name = "${var.name}-cloudfront"
  }

  provider = aws.main
}

