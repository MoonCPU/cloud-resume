terraform {
   required_providers {
     aws = {
       source  = "hashicorp/aws"
       version = "5.92.0"
     }
   }

  backend "s3" {}
 }
 
 provider "aws" {
   region = var.aws_region
 }

// 1- setting up s3 for hosting static website

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.s3_bucket_name

    lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# blocking public access for security, cloudfront will serve the website content without exposing the s3 bucket
resource "aws_s3_bucket_public_access_block" "frontend_access_block" {
  bucket = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

variable "frontend_files" {
  type    = map(string)
  default = {
    "index.html"    = "../app/index.html"
    "style.css"     = "../app/style.css"
    "main.js"       = "../app/main.js"
    "images/github.png"   = "../app/images/github.png"
    "images/kilroy.png"   = "../app/images/kilroy.png"
    "images/linkedin.png" = "../app/images/linkedin.png"
  }
}

resource "aws_s3_object" "frontend_files" {
  for_each     = var.frontend_files
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = each.key
  source       = each.value
  etag         = filemd5(each.value)

  content_type = lookup(
    {
      "index.html"             = "text/html"
      "style.css"              = "text/css"
      "main.js"                = "application/javascript"
      "images/github.png"      = "image/png"
      "images/kilroy.png"      = "image/png"
      "images/linkedin.png"    = "image/png"
    },
    each.key,
    "application/octet-stream" # fallback
  )
}

// 2 - setting up cloudfront

# the origin access control will access the private s3 bucket without making the bucket public
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "frontend-s3-oac"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    # this tells where cloud front fetch content from, in this case, the s3 "frontend_bucket" bucket
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    # custom name to identify this cloud front origin
    origin_id                = "frontendS3Origin"
    # links to the "s3_oac" oac 
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    # users can only send GET or HEAD request, and not other HTTP methods
    allowed_methods  = ["GET", "HEAD"]
    # cloudfront will only cache GET and HEAD operations, and not other HTTP methods
    cached_methods   = ["GET", "HEAD"]
    # this tells which origin to use
    target_origin_id = "frontendS3Origin"

    # forces all users to use HTTPS instead of HTTP.
    viewer_protocol_policy = "redirect-to-https"
    # reduce size of files for faster loading
    compress               = true

    forwarded_values {
      # ignores query parameters in url
      query_string = false
      # cloudfront will not forward cookies to the s3
      cookies {
        forward = "none"
      }
    }
  }

  # determines which edge locations to store cache
  # PriceClass_100 is the cheapest region: US, Canada, Europe
  price_class = "PriceClass_100"

  restrictions {
    # no restriction on locations where users can access my website
    geo_restriction {
      restriction_type = "none"
    }
  }

  # provide SSL certificate
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Alternate domain name (CNAME)
  aliases = [
    "moondev-cloud.com",
    "www.moondev-cloud.com"
  ]
}

// allow cloudfront to access the private S3 bucket
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend_distribution.arn
          }
        }
      }
    ]
  })
}

// 3- setting up route53 to use our custom domain name

resource "aws_route53_record" "frontend_record" {
  zone_id = var.hosted_zone_id 
  name    = "moondev-cloud.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_www_record" {
  zone_id = var.hosted_zone_id  
  name    = "www.moondev-cloud.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}