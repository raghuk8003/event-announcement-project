provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "event_website" {
  bucket        = "event-announcement-azhar"  # Change this to a globally unique name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_hosting" {
  bucket = aws_s3_bucket.event_website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.event_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.event_website.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.event_website.arn}/*"
      }
    ]
  })
}
