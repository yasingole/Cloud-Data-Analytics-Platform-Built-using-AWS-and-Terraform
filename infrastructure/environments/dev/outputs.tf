#VPC OUTPUTS
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of IDs of private application subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of IDs of private database subnets"
  value       = module.vpc.private_db_subnet_ids
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = module.vpc.private_route_table_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (if created)"
  value       = module.vpc.nat_gateway_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

#S3 OUTPUTS
output "raw_data_bucket" {
  description = "Raw data S3 bucket name"
  value       = module.s3.raw_data_bucket
}

output "raw_data_bucket_arn" {
  description = "Raw data S3 bucket ARN"
  value       = module.s3.raw_data_bucket_arn
}

output "processed_data_bucket" {
  description = "Processed data S3 bucket name"
  value       = module.s3.processed_data_bucket
}

output "processed_data_bucket_arn" {
  description = "Processed data S3 bucket ARN"
  value       = module.s3.processed_data_bucket_arn
}

output "website_bucket" {
  description = "Website S3 bucket name"
  value       = module.s3.website_bucket
}

output "website_bucket_arn" {
  description = "Website S3 bucket ARN"
  value       = module.s3.website_bucket_arn
}

output "website_endpoint" {
  description = "Website S3 bucket website endpoint"
  value       = module.s3.website_endpoint
}

output "website_domain" {
  description = "Website S3 bucket website domain"
  value       = module.s3.website_domain
}

#EC2 OUTPUTS
output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.ec2.security_group_id
}

output "ec2_security_group_name" {
  description = "Name of the EC2 security group"
  value       = module.ec2.security_group_name
}

output "ec2_iam_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = module.ec2.iam_role_arn
}

output "ec2_iam_role_name" {
  description = "Name of the IAM role for EC2 instances"
  value       = module.ec2.iam_role_name
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = module.ec2.instance_profile_name
}

output "ec2_launch_template_id" {
  description = "ID of the launch template"
  value       = module.ec2.launch_template_id
}

output "ec2_autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.autoscaling_group_name
}

# RDS OUTPUTS
output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = module.rds.db_instance_port
}

output "db_name" {
  description = "Name of the database"
  value       = module.rds.db_name
}

output "db_username" {
  description = "Username for the database"
  value       = module.rds.db_username
}

output "db_security_group_id" {
  description = "ID of the security group for the RDS instance"
  value       = module.rds.security_group_id
}

output "db_parameter_group_id" {
  description = "ID of the DB parameter group"
  value       = module.rds.parameter_group_id
}

output "db_password_parameter" {
  description = "SSM parameter name for the database password"
  value       = module.rds.ssm_parameter_db_password
}

# Lambda OUTPUTS
output "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda functions"
  value       = module.lambda.lambda_role_arn
}

output "lambda_role_name" {
  description = "Name of the IAM role for Lambda functions"
  value       = module.lambda.lambda_role_name
}

output "data_validation_lambda_arn" {
  description = "ARN of the data validation Lambda function"
  value       = module.lambda.data_validation_lambda_arn
}

output "data_validation_lambda_name" {
  description = "Name of the data validation Lambda function"
  value       = module.lambda.data_validation_lambda_name
}

output "api_lambda_arn" {
  description = "ARN of the API Lambda function"
  value       = module.lambda.api_lambda_arn
}

output "api_lambda_invoke_arn" {
  description = "Invoke ARN of the API Lambda function"
  value       = module.lambda.api_lambda_invoke_arn
}

output "api_lambda_name" {
  description = "Name of the API Lambda function"
  value       = module.lambda.api_lambda_name
}

# API Gateway OUTPUTS
output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = module.api_gw.api_gateway_id
}

output "api_gateway_name" {
  description = "Name of the API Gateway REST API"
  value       = module.api_gw.api_gateway_name
}

output "api_gateway_invoke_url" {
  description = "URL to invoke the API Gateway"
  value       = module.api_gw.api_gateway_invoke_url
}

output "api_endpoints" {
  description = "List of API endpoint URLs"
  value       = {
    summary = "${module.api_gw.api_gateway_invoke_url}api/summary"
    # Add more endpoints as they are created
  }
}
