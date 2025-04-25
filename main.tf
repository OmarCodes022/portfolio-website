terraform {
  backend "s3" {
    bucket         = "omarahmed-portfolio-site"
    key            = "terraform/terraform.tfstate"
    region         = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"  # Paris region, or change if needed
}

#resource "aws_s3_bucket" "portfolio" {
#  bucket = "omarahmed-portfolio-site"  # MUST be unique across all AWS
#
#  website {
#    index_document = "index.html"
#    error_document = "404.html"
#  }
#
#  tags = {
#    Name        = "OmarAhmedPortfolio"
#    Environment = "Dev"
#  }
#}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.portfolio.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = "${aws_s3_bucket.portfolio.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_object" "website_files" {
  for_each = fileset("${path.module}/site", "**/*")

  bucket       = aws_s3_bucket.portfolio.id
  key          = each.value
  source       = "${path.module}/site/${each.value}"
  etag         = filemd5("${path.module}/site/${each.value}")
  content_type = lookup({
    html = "text/html",
    css  = "text/css",
    js   = "application/javascript",
    png  = "image/png",
    jpg  = "image/jpeg",
    jpeg = "image/jpeg",
    svg  = "image/svg+xml"
  }, split(".", each.value)[length(split(".", each.value)) - 1], null)
}
