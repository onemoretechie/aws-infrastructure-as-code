locals {
  base_tags = merge(
    {
      Module    = "cloudfront"
      ManagedBy = "terraform"
    },
    var.tags,
  )

  is_s3_origin     = var.s3_origin != null
  is_custom_origin = var.custom_origin != null

  origin_id = "${var.name}-origin"

  # AWS-managed cache policies. Used as a fallback when no policy is supplied.
  default_cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
}

resource "aws_cloudfront_origin_access_control" "this" {
  count = local.is_s3_origin ? 1 : 0

  name                              = "${var.name}-oac"
  description                       = "OAC for ${var.name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment != null ? var.comment : var.name
  price_class         = var.price_class
  default_root_object = var.default_root_object
  aliases             = var.aliases
  web_acl_id          = var.web_acl_id

  dynamic "origin" {
    for_each = local.is_s3_origin ? [var.s3_origin] : []
    content {
      origin_id                = local.origin_id
      domain_name              = origin.value.bucket_regional_domain_name
      origin_path              = origin.value.origin_path
      origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
    }
  }

  dynamic "origin" {
    for_each = local.is_custom_origin ? [var.custom_origin] : []
    content {
      origin_id   = local.origin_id
      domain_name = origin.value.domain_name
      origin_path = origin.value.origin_path

      custom_origin_config {
        http_port                = origin.value.http_port
        https_port               = origin.value.https_port
        origin_protocol_policy   = origin.value.origin_protocol_policy
        origin_ssl_protocols     = origin.value.origin_ssl_protocols
        origin_read_timeout      = origin.value.origin_read_timeout
        origin_keepalive_timeout = origin.value.origin_keepalive_timeout
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    compress               = var.default_cache_behavior.compress

    cache_policy_id            = var.default_cache_behavior.cache_policy_id != null ? var.default_cache_behavior.cache_policy_id : local.default_cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id
  }

  viewer_certificate {
    cloudfront_default_certificate = var.certificate_arn == null
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = var.certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.certificate_arn != null ? var.minimum_protocol_version : "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  dynamic "logging_config" {
    for_each = var.logging != null ? [var.logging] : []
    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  tags = merge(local.base_tags, { Name = var.name })

  lifecycle {
    precondition {
      condition     = (local.is_s3_origin && !local.is_custom_origin) || (!local.is_s3_origin && local.is_custom_origin)
      error_message = "Exactly one of s3_origin or custom_origin must be set."
    }
  }
}

# Bucket policy that lets this distribution read from the S3 origin
data "aws_iam_policy_document" "s3_oac" {
  count = local.is_s3_origin ? 1 : 0

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${var.s3_origin.bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "origin" {
  count = local.is_s3_origin ? 1 : 0

  bucket = split(".", var.s3_origin.bucket_regional_domain_name)[0]
  policy = data.aws_iam_policy_document.s3_oac[0].json
}
