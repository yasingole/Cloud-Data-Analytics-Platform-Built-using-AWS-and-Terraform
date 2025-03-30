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
