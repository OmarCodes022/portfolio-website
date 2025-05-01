
#Define the backend configuration to store Terraform state remotely in an S3 bucket
terraform {
  backend "s3" {
    bucket = "omarahmed-portfolio-site"
    key    = "terraform/terraform.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"
}

#Create an S3 bucket to host the static portfolio website
resource "aws_s3_bucket" "portfolio" {
  bucket = "omarahmed-portfolio-site"  #unique

  #Enable static website hosting with index and error pages
  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  #optionnel
  tags = {
    Name        = "OmarAhmedPortfolio"
    Environment = "Dev"
  }
}

# Define a bucket policy to make all objects publicly readable
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.portfolio.id  # Attach policy to the bucket

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

#Upload all website files from /site directory to the S3 bucket
resource "aws_s3_bucket_object" "website_files" {
  for_each = fileset("${path.module}/site", "**/*")  #Loop through all files recursively in /site and then it creates an object for each
  bucket       = aws_s3_bucket.portfolio.id
  key          = each.value
  source       = "${path.module}/site/${each.value}"


 etag         = filemd5("${path.module}/site/${each.value}")   # Hash for detecting file changes
 # The `etag` is set to the MD5 hash of the file content.
 # This allows Terraform to detect if the file has changed since the last apply.
 #
 # How it works:
 # - `filemd5(...)` calculates a fingerprint of the file.
 # - Terraform saves this value in the .tfstate file.
 # - On the next `terraform apply`, it:
 #     - Recalculates the MD5 hash.
 #     - Compares it to the stored value.
 #     - If the hash has changed → re-uploads the file.
 #     - If the hash is the same → no action is taken.


  #set the appropriate tag type for each file (optionel aws treats it auto already but its better to excplicitly state it)
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
