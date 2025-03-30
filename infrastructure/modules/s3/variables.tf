variable "project_name" {
  description = "Name of the project to use in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN of CloudFront distribution to add to bucket policy"
  type        = string
  default     = ""
}
