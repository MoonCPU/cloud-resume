module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["www.moondev-cloud.com"]

  # connect to S3
  origin = {
    s3_website = {
      domain_name = var.s3_bucket_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only" # S3 website only supports HTTP
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  # force HTTPS and optimize caching
  default_cache_behavior = {
    target_origin_id       = "s3_website"
    viewer_protocol_policy = "redirect-to-https" # Auto-upgrades HTTP → HTTPS
    allowed_methods        = ["GET", "HEAD"]     # Static sites only need these
    cached_methods         = ["GET", "HEAD"]
  }

  # SSL certificate (auto-validated via Route 53)
  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

# Request SSL certificate
module "acm" {
  source            = "terraform-aws-modules/acm/aws"
  domain_name       = "moondev-cloud.com"
  zone_id           = var.hosted_zone_id
  validation_method = "DNS"
}