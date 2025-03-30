terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Call the S3 module
module "frontend_s3_bucket" {
  source     = "./modules/s3"
  aws_region = var.aws_region
}