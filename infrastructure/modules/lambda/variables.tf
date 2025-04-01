# infrastructure/modules/lambda/variables.tf

variable "project_name" {
  description = "Name of the project to use in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "raw_data_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  type        = string
}

variable "raw_data_bucket_name" {
  description = "Name of the raw data S3 bucket"
  type        = string
}

variable "processed_data_bucket_arn" {
  description = "ARN of the processed data S3 bucket"
  type        = string
}

variable "processed_data_bucket_name" {
  description = "Name of the processed data S3 bucket"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the Lambda functions will be deployed"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs where the Lambda functions will be deployed"
  type        = list(string)
  default     = null
}

variable "validation_zip_path" {
  description = "Path to the ZIP file containing the data validation Lambda code"
  type        = string
}

variable "api_zip_path" {
  description = "Path to the ZIP file containing the API Lambda code"
  type        = string
}

variable "layer_zip_path" {
  description = "Path to the ZIP file containing Lambda layer dependencies"
  type        = string
  default     = ""
}

variable "create_dependencies_layer" {
  description = "Whether to create a Lambda layer for dependencies"
  type        = bool
  default     = false
}

variable "enable_rds_access" {
  description = "Whether to enable RDS access for Lambda functions"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Database username for RDS access"
  type        = string
  default     = "admin"
}
