output "website_url" {
  description = "Static website URL"
  value       = aws_s3_bucket_website_configuration.static_hosting.website_endpoint
}
