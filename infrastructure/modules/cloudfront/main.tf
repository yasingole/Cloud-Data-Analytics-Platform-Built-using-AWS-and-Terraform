#Cloudfront distribution

#Cloudfront origin access identity

#Update S3 bucket policy to allow cloudfront access

# CloudFront Function for security headers (optional)
resource "aws_cloudfront_function" "security_headers" {
  name    = "${var.project_name}-${var.environment}-security-headers"
  runtime = "cloudfront-js-1.0"
  comment = "Add security headers to all responses"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var response = event.response;
      var headers = response.headers;

      // Add security headers
      headers['strict-transport-security'] = { value: 'max-age=31536000; includeSubdomains; preload' };
      headers['x-content-type-options'] = { value: 'nosniff' };
      headers['x-frame-options'] = { value: 'DENY' };
      headers['x-xss-protection'] = { value: '1; mode=block' };
      headers['content-security-policy'] = {
        value: "default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self'; font-src 'self';"
      };

      return response;
    }
  EOT
}
