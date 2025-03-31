variable "project_name" {
  description = "Name of the project to use in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "stage_name" {
  description = "Name of the API Gateway deployment stage"
  type        = string
  default     = "dev"
}

variable "lambda_invoke_arn" {
  description = "ARN of the Lambda function to invoke"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
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

variable "cors_allow_headers" {
  description = "List of headers to allow for CORS"
  type        = list(string)
  default     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "log_retention_days" {
  description = "Number of days to retain API Gateway logs"
  type        = number
  default     = 30
}

variable "enable_api_key" {
  description = "Whether to enable API key authentication"
  type        = bool
  default     = false
}

variable "api_key_required_endpoints" {
  description = "List of endpoint paths that require an API key (if enable_api_key is true)"
  type        = list(string)
  default     = []
}
