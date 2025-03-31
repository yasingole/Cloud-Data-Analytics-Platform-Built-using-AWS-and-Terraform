#VPC variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = false
}

# Project-wide variables
variable "project_name" {
  description = "Name of the project to use in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}


# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type for data processing servers"
  type        = string
  default     = "t3.small"
}


variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host (if any)"
  type        = string
  default     = ""
}

#RDS variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "Data"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB for autoscaling"
  type        = number
  default     = 100
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting the instance"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}

#Lambda variables
variable "lambda_memory_size" {
  description = "Memory size for Lambda functions (in MB)"
  type        = number
  default     = 256
}

variable "validation_timeout" {
  description = "Timeout for data validation Lambda (in seconds)"
  type        = number
  default     = 60
}

variable "api_timeout" {
  description = "Timeout for API Lambda (in seconds)"
  type        = number
  default     = 30
}

variable "create_dependencies_layer" {
  description = "Whether to create a Lambda layer for dependencies"
  type        = bool
  default     = false
}

variable "layer_zip_path" {
  description = "Path to the ZIP file containing Lambda layer dependencies"
  type        = string
  default     = ""
}

variable "enable_rds_access" {
  description = "Whether to enable RDS access for Lambda functions"
  type        = bool
  default     = false
}

# API Gateway Variables
variable "stage_name" {
  description = "Name of the API Gateway deployment stage"
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "Number of days to retain API Gateway logs"
  type        = number
  default     = 30
}

variable "cors_allow_origins" {
  description = "List of origins to allow for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "List of methods to allow for CORS"
  type        = list(string)
  default     = ["GET", "POST", "OPTIONS"]
}

variable "enable_api_key" {
  description = "Whether to enable API key authentication"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "notification_email" {
  description = "Email address to receive monitoring alerts"
  type        = string
  default     = null
}

# Monitoring Thresholds
variable "cpu_threshold" {
  description = "CPU utilization threshold for triggering alarms"
  type        = number
  default     = 80
}

variable "error_threshold" {
  description = "Error count threshold for Lambda and other services"
  type        = number
  default     = 1
}

# Specific Monitoring Toggles
variable "monitor_rds" {
  description = "Enable monitoring for RDS instances"
  type        = bool
  default     = true
}

variable "monitor_lambdas" {
  description = "Enable monitoring for Lambda functions"
  type        = bool
  default     = true
}

variable "monitor_ec2" {
  description = "Enable monitoring for EC2 Auto Scaling Group"
  type        = bool
  default     = true
}

variable "monitor_s3" {
  description = "Enable monitoring for S3 buckets"
  type        = bool
  default     = true
}

# Logging and Retention
variable "log_retention_days" {
  description = "Number of days to retain logs for monitoring resources"
  type        = number
  default     = 30
}
