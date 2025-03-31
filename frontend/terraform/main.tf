module "frontend_s3_bucket" {
  source     = "./modules/s3"
  aws_region = var.aws_region
}

module "route53_zones" {
  source = "./modules/route53"
  domain_name = var.domain_name
}

module "cloudfront" {
  source = "./modules/cloudFront"
  s3_bucket_domain_name = module.frontend_s3_bucket.regional_domain_name
  hosted_zone_id = module.route53_zones.hosted_zone_id
}

module "route53_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.domain_name 

  records = [
    {
      name = ""
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    },
    {
      name = "www"
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]
}