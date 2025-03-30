# infrastructure/modules/ec2/variables.tf

variable "project_name" {
  description = "Name of the project to use in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances will be launched"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the EC2 instances will be launched"
  type        = list(string)
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host (if any)"
  type        = string
  default     = ""
}

variable "raw_data_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  type        = string
}

variable "processed_data_bucket_arn" {
  description = "ARN of the processed data S3 bucket"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID to use for the instances (if empty, latest Amazon Linux 2 will be used)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default     = ""
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
