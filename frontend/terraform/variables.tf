variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "domain_name" {
  description = "The registered domain name"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the existing ACM certificate for CloudFront"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of S3 bucket"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route 53 hosted zone ID for moondev-cloud.com"
  type        = string
}