#IAM role for lambda functions
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-role"
    Environment = var.environment
  }
}

#Data validation laambda function
resource "aws_lambda_function" "data_validation" {
  function_name = "${var.project_name}-data-validation"
  description   = "Validates uploaded data"
  role          = aws_iam_role.lambda.arn
  handler       = "validation.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  memory_size   = 256

  filename         = var.validation_zip_path
  source_code_hash = filebase64sha256(var.validation_zip_path)

  environment {
    variables = {
      RAW_BUCKET       = var.raw_data_bucket_name
      PROCESSED_BUCKET = var.processed_data_bucket_name
      PROJECT_NAME     = var.project_name
    }
  }

  tags = {
    Name = "${var.project_name}-data-validation-lambda"
    Environment = var.environment
  }
}

#API lambda
resource "aws_lambda_function" "api" {
  function_name = "${var.project_name}-api"
  description   = "API for data platform"
  role          = aws_iam_role.lambda.arn
  handler       = "api.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 256

  filename         = var.api_zip_path
  source_code_hash = filebase64sha256(var.api_zip_path)


  environment {
    variables = {
      DB_PARAM_PATH    = "/${var.project_name}/${var.environment}/db"
      PROCESSED_BUCKET = var.processed_data_bucket_name
      PROJECT_NAME     = var.project_name
    }
  }

  tags = {
    Name = "${var.project_name}-api-lambda"
    Environment = var.environment
  }
}

#S3 trigger for data validation lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_validation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.raw_data_bucket_arn
}

#S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.raw_data_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_validation.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".csv"
  }

  #permission created before the notification
  depends_on = [aws_lambda_permission.allow_s3]
}

#CloudWatch log groups
resource "aws_cloudwatch_log_group" "data_validation" {
  name              = "/aws/lambda/${aws_lambda_function.data_validation.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-data-validation-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-api-logs"
    Environment = var.environment
  }
}

#IAM
#CloudWatch Logs policy
resource "aws_iam_policy" "lambda_logs" {
  name        = "${var.project_name}-${var.environment}-lambda-logs"
  description = "IAM policy for logging from Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${var.project_name}-*"
      }
    ]
  })
}

#S3 access policy
resource "aws_iam_policy" "lambda_s3" {
  name        = "${var.project_name}-${var.environment}-lambda-s3"
  description = "IAM policy for S3 access from Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          var.raw_data_bucket_arn,
          "${var.raw_data_bucket_arn}/*",
          var.processed_data_bucket_arn,
          "${var.processed_data_bucket_arn}/*"
        ]
      }
    ]
  })
}

#SSM Parameter Store access policy
resource "aws_iam_policy" "lambda_ssm" {
  name        = "${var.project_name}-${var.environment}-lambda-ssm"
  description = "IAM policy for SSM Parameter Store access from Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

# VPC access policy (only needed FOR Lambda functions that need to access VPC resources like RDS)
resource "aws_iam_policy" "lambda_vpc" {
  count       = var.enable_rds_access ? 1 : 0
  name        = "${var.project_name}-${var.environment}-lambda-vpc"
  description = "IAM policy for VPC access from Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policies to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ssm" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_ssm.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = var.enable_rds_access ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_vpc[0].arn
}

# Basic Lambda execution role (includes CloudWatch permissions)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
