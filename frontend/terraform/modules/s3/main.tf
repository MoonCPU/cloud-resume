module "frontend_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "moon-cloud-ops-s3"
  acl    = "public-read"

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = module.frontend_s3_bucket.s3_bucket_id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = module.frontend_s3_bucket.s3_bucket_id

  //this tells terraform to load the index.html when the user visits the website
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

//upload the index.html, style.css and main.js to the s3 bucket
resource "aws_s3_object" "index_html" {
  bucket       = module.frontend_s3_bucket.s3_bucket_id
  key          = "index.html"
  source       = "../../../app/index.html"
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "style_css" {
  bucket       = module.frontend_s3_bucket.s3_bucket_id
  key          = "style.css"
  source       = "../../../app/style.css"
  content_type = "text/css"
  acl          = "public-read"
}

resource "aws_s3_object" "main_js" {
  bucket       = module.frontend_s3_bucket.s3_bucket_id
  key          = "main.js"
  source       = "../../../app/main.js"
  content_type = "application/javascript"
  acl          = "public-read"
}

//uploading the images to s3 bucket 
resource "aws_s3_object" "github_logo" {
  bucket       = module.frontend_s3_bucket.s3_bucket_id
  key          = "images/github.png" # Maintain folder structure in S3
  source       = "../../../app/images/github.png"
  content_type = "image/png"
  acl          = "public-read"
}

resource "aws_s3_object" "linkedin_logo" {
  bucket       = module.frontend_s3_bucket.s3_bucket_id
  key          = "images/linkedin.png"
  source       = "../../../app/images/linkedin.png"
  content_type = "image/png"
  acl          = "public-read"
}

resource "aws_s3_object" "kilroy_logo" {
  bucket       = module.frontend_s3_bucket.s3_bucket_id
  key          = "images/kilroy.png"
  source       = "../../../app/images/kilroy.png"
  content_type = "image/png"
  acl          = "public-read"
}

//setting up policy and permissions
data "aws_iam_policy_document" "frontend_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.frontend_s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  #   statement {
  #   effect    = "Deny"
  #   actions   = ["s3:*"]  # Applies to all S3 actions
  #   resources = ["${module.frontend_s3_bucket.s3_bucket_arn}/*"]
  #   principals {
  #     type        = "*"
  #     identifiers = ["*"]
  #   }
  #   condition {
  #     test     = "Bool"
  #     variable = "aws:SecureTransport"
  #     values   = ["false"]  # Blocks HTTP requests
  #   }
  # }

  statement {
    effect    = "Deny"
    actions   = ["s3:DeleteObject"]
    resources = ["${module.frontend_s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = module.frontend_s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.frontend_policy.json
}