variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

# RDS Monitoring
variable "monitor_rds" {
  description = "Enable RDS monitoring"
  type        = bool
  default     = true
}

variable "rds_instance_id" {
  description = "RDS instance ID to monitor"
  type        = string
  default     = null
}

# Lambda Monitoring
variable "monitor_lambdas" {
  description = "Enable Lambda function monitoring"
  type        = bool
  default     = true
}

variable "lambda_function_names" {
  description = "List of Lambda function names to monitor"
  type        = list(string)
  default     = []
}

# EC2 Monitoring
variable "monitor_ec2" {
  description = "Enable EC2 monitoring"
  type        = bool
  default     = true
}

variable "asg_name" {
  description = "Auto Scaling Group name to monitor"
  type        = string
  default     = null
}

# S3 Monitoring
variable "monitor_s3" {
  description = "Enable S3 bucket monitoring"
  type        = bool
  default     = true
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names to monitor"
  type        = list(string)
  default     = []
}

# Alarm Configurations
variable "error_threshold" {
  description = "Error threshold for alarms"
  type        = number
  default     = 1
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "notification_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = null
}
