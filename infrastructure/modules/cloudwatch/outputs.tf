output "sns_topic_arn" {
  description = "ARN of the SNS topic for monitoring alerts"
  value       = var.notification_email != null ? aws_sns_topic.monitoring_alerts[0].arn : null
}

output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS CPU utilization alarm"
  value       = var.monitor_rds && var.rds_instance_id != null ? aws_cloudwatch_metric_alarm.rds_cpu_utilization[0].arn : null
}

output "rds_storage_alarm_arn" {
  description = "ARN of the RDS storage space alarm"
  value       = var.monitor_rds && var.rds_instance_id != null ? aws_cloudwatch_metric_alarm.rds_free_storage[0].arn : null
}

output "lambda_error_alarm_arns" {
  description = "ARNs of Lambda error alarms"
  value       = var.monitor_lambdas ? aws_cloudwatch_metric_alarm.lambda_errors[*].arn : []
}

output "asg_cpu_alarm_arn" {
  description = "ARN of the EC2 Auto Scaling Group CPU utilization alarm"
  value       = var.monitor_ec2 && var.asg_name != null ? aws_cloudwatch_metric_alarm.asg_cpu_utilization[0].arn : null
}

output "s3_size_alarm_arns" {
  description = "ARNs of S3 bucket size alarms"
  value       = var.monitor_s3 ? aws_cloudwatch_metric_alarm.s3_bucket_size[*].arn : []
}
