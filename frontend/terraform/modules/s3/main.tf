module "frontend_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-website-bucket"
  acl    = "public-read"  

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = module.frontend_s3_bucket.bucket

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
    bucket = module.frontend_s3_bucket.bucket
    key    = "index.html"
    source = "../../../app/index.html"
    content_type = "text/html"
    acl          = "public-read"
}

resource "aws_s3_object" "style_css" {
  bucket       = module.frontend_s3_bucket.bucket
  key          = "style.css"
  source       = "../../../app/style.css"
  content_type = "text/css"
  acl          = "public-read"
}

resource "aws_s3_object" "main_js" {
  bucket       = module.frontend_s3_bucket.bucket
  key          = "main.js"
  source       = "../../../app/main.js"
  content_type = "application/javascript"
  acl          = "public-read"
}

//uploading the images to s3 bucket 
resource "aws_s3_object" "github_logo" {
  bucket       = module.frontend_s3_bucket.bucket
  key          = "images/github.png"  # Maintain folder structure in S3
  source       = "../../../app/images/github.png"
  content_type = "image/png"
  acl          = "public-read"
}

resource "aws_s3_object" "linkedin_logo" {
  bucket       = module.frontend_s3_bucket.bucket
  key          = "images/linkedin.png"
  source       = "../../../app/images/linkedin.png"
  content_type = "image/png"
  acl          = "public-read"
}

resource "aws_s3_object" "kilroy_logo" {
  bucket       = module.frontend_s3_bucket.bucket
  key          = "images/kilroy.png"
  source       = "../../../app/images/kilroy.png"
  content_type = "image/png"
  acl          = "public-read"
}