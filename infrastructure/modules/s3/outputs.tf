output "raw_data_bucket" {
  description = "Raw data S3 bucket name"
  value       = aws_s3_bucket.raw_data.bucket
}

output "raw_data_bucket_arn" {
  description = "Raw data S3 bucket ARN"
  value       = aws_s3_bucket.raw_data.arn
}

output "raw_data_bucket_id" {
  description = "Raw data S3 bucket ID"
  value       = aws_s3_bucket.raw_data.id
}

output "processed_data_bucket" {
  description = "Processed data S3 bucket name"
  value       = aws_s3_bucket.processed_data.bucket
}

output "processed_data_bucket_arn" {
  description = "Processed data S3 bucket ARN"
  value       = aws_s3_bucket.processed_data.arn
}

output "processed_data_bucket_id" {
  description = "Processed data S3 bucket ID"
  value       = aws_s3_bucket.processed_data.id
}

output "website_bucket" {
  description = "Website S3 bucket name"
  value       = aws_s3_bucket.website.bucket
}

output "website_bucket_arn" {
  description = "Website S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "website_bucket_id" {
  description = "Website S3 bucket ID"
  value       = aws_s3_bucket.website.id
}

output "website_endpoint" {
  description = "Website S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_domain" {
  description = "Website S3 bucket website domain"
  value       = aws_s3_bucket_website_configuration.website.website_domain
}
