output "website_url" {
  description = "URL of the S3 website endpoint (HTTP only)"
  value       = "http://${module.frontend_s3_bucket.s3_bucket_id}.s3-website-${var.aws_region}.amazonaws.com"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.frontend_s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.frontend_s3_bucket.s3_bucket_arn
}

output "website_endpoint" {
  description = "S3 website endpoint (for DNS records)"
  value       = module.frontend_s3_bucket.s3_bucket_website_endpoint
}

output "regional_domain_name" {
  description = "S3 bucket regional domain name (for CloudFront origins)"
  value       = module.frontend_s3_bucket.s3_bucket_bucket_regional_domain_name
}