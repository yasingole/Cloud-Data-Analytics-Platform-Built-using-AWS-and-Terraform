#Raw data bucket
resource "aws_s3_bucket" "raw_data" {
  bucket = var.project_name

  tags = {
    Name        = "${var.project_name}-raw-data-${random_string.suffix.result}"
    Environment = var.environment
  }
}
#Enable sse for raw data bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Processed data bucket
resource "aws_s3_bucket" "processed_data" {
  bucket = "${var.project_name}-processed-data-${var.environment}-${random_string.suffix.result}"

  tags = {
    Name        = "${var.project_name}-processed-data"
    Environment = var.environment
  }
}
#Enable sse for processed data bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "processed_data" {
  bucket = aws_s3_bucket.processed_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Website bucket
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${var.environment}-${random_string.suffix.result}"

  tags = {
    Name        = "${var.project_name}-website"
    Environment = var.environment
  }
}

#Enable website hosting for website bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#Enable versioning for both raw and processed bucket
resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_versioning" "processed_data" {
  bucket = aws_s3_bucket.processed_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Block public access for:
#Raw data bucket
#Processed data bucket
resource "aws_s3_bucket_public_access_block" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "processed_data" {
  bucket = aws_s3_bucket.processed_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Random string resource
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
