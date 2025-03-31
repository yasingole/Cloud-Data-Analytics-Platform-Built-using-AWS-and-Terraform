provider "aws" {
  region  = var.aws_region
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Archive files for Lambda functions
data "archive_file" "validation_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_packages/validation.zip"
  source_file = "${path.module}/../../src/data-processing/validation.py"
}

data "archive_file" "api_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_packages/api.zip"
  source_file = "${path.module}/../../src/api/api.py"
}

#Modules
module "vpc" {
  source = "../../modules/vpc"

  project_name              = var.project_name
  environment               = var.environment
  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_db_subnet_cidrs   = var.private_db_subnet_cidrs
  create_nat_gateway        = var.create_nat_gateway
  enable_flow_logs          = var.enable_flow_logs
}

module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment = var.environment
}

module "ec2" {
  source = "../../modules/ec2"

  project_name = var.project_name
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_app_subnet_ids
  raw_data_bucket_arn = module.s3.raw_data_bucket_arn
  processed_data_bucket_arn = module.s3.processed_data_bucket_arn
}

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_db_subnet_ids
  ec2_security_group_ids = [module.ec2.security_group_id]

  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  db_username             = var.db_username
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  engine_version          = var.engine_version
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
}

module "lambda" {
  source = "../../modules/lambda"

  project_name               = var.project_name
  environment                = var.environment
  raw_data_bucket_arn        = module.s3.raw_data_bucket_arn
  raw_data_bucket_name       = module.s3.raw_data_bucket
  processed_data_bucket_arn  = module.s3.processed_data_bucket_arn
  processed_data_bucket_name = module.s3.processed_data_bucket

  #Lambda function code
  validation_zip_path        = data.archive_file.validation_lambda.output_path
  api_zip_path               = data.archive_file.api_lambda.output_path

  #For database access
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_app_subnet_ids
  enable_rds_access          = true
  db_username                = module.rds.db_username
}

module "api_gw" {
  source = "../../modules/api_gw"

  project_name           = var.project_name
  environment            = var.environment
  lambda_invoke_arn      = module.lambda.api_lambda_invoke_arn
  lambda_function_name   = module.lambda.api_lambda_name

  # Optional parameters
  stage_name             = var.environment
  log_retention_days     = var.log_retention_days
  cors_allow_origins     = var.cors_allow_origins
  cors_allow_methods     = var.cors_allow_methods
  enable_api_key         = var.enable_api_key
}
