output "bucket_id" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for the S3 bucket"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = aws_s3_bucket.main.region
}

output "website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.main[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain of the S3 bucket"
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.main[0].website_domain : null
}