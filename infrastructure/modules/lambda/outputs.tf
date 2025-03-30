output "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda functions"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "Name of the IAM role for Lambda functions"
  value       = aws_iam_role.lambda.name
}

output "data_validation_lambda_arn" {
  description = "ARN of the data validation Lambda function"
  value       = aws_lambda_function.data_validation.arn
}

output "data_validation_lambda_invoke_arn" {
  description = "Invoke ARN of the data validation Lambda function"
  value       = aws_lambda_function.data_validation.invoke_arn
}

output "data_validation_lambda_name" {
  description = "Name of the data validation Lambda function"
  value       = aws_lambda_function.data_validation.function_name
}

output "data_validation_lambda_qualified_arn" {
  description = "Qualified ARN of the data validation Lambda function"
  value       = aws_lambda_function.data_validation.qualified_arn
}

output "api_lambda_arn" {
  description = "ARN of the API Lambda function"
  value       = aws_lambda_function.api.arn
}

output "api_lambda_invoke_arn" {
  description = "Invoke ARN of the API Lambda function"
  value       = aws_lambda_function.api.invoke_arn
}

output "api_lambda_name" {
  description = "Name of the API Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "api_lambda_qualified_arn" {
  description = "Qualified ARN of the API Lambda function"
  value       = aws_lambda_function.api.qualified_arn
}

output "data_validation_log_group_name" {
  description = "Name of the CloudWatch Log Group for the data validation Lambda"
  value       = aws_cloudwatch_log_group.data_validation.name
}

output "api_log_group_name" {
  description = "Name of the CloudWatch Log Group for the API Lambda"
  value       = aws_cloudwatch_log_group.api.name
}
