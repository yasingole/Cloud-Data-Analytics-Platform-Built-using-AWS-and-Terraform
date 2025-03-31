#SNS Topic for Notifications
resource "aws_sns_topic" "monitoring_alerts" {
  count = var.notification_email != null ? 1 : 0
  name = "${var.project_name}-${var.environment}-monitoring-alerts"
}

#SNS Topic Subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  count     = var.notification_email != null ? 1 : 0
  topic_arn = aws_sns_topic.monitoring_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

#RDS Monitoring Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  count               = var.monitor_rds && var.rds_instance_id != null ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_description = "RDS CPU utilization is above ${var.cpu_threshold}%"
  alarm_actions     = var.notification_email != null ? [aws_sns_topic.monitoring_alerts[0].arn] : []
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  count               = var.monitor_rds && var.rds_instance_id != null ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = 5000000000  # 5GB

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_description = "RDS free storage is below 5GB"
  alarm_actions     = var.notification_email != null ? [aws_sns_topic.monitoring_alerts[0].arn] : []
}

#Lambda Monitoring Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = var.monitor_lambdas ? length(var.lambda_function_names) : 0
  alarm_name          = "${var.project_name}-${var.environment}-${var.lambda_function_names[count.index]}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.error_threshold

  dimensions = {
    FunctionName = var.lambda_function_names[count.index]
  }

  alarm_description = "Lambda function ${var.lambda_function_names[count.index]} has high error rate"
  alarm_actions     = var.notification_email != null ? [aws_sns_topic.monitoring_alerts[0].arn] : []
}

#EC2 Auto Scaling Group Monitoring
resource "aws_cloudwatch_metric_alarm" "asg_cpu_utilization" {
  count               = var.monitor_ec2 && var.asg_name != null ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "EC2 Auto Scaling Group CPU utilization is above ${var.cpu_threshold}%"
  alarm_actions     = var.notification_email != null ? [aws_sns_topic.monitoring_alerts[0].arn] : []
}

#S3 Bucket Monitoring
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  count               = var.monitor_s3 ? length(var.s3_bucket_names) : 0
  alarm_name          = "${var.project_name}-${var.environment}-${var.s3_bucket_names[count.index]}-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"  # 24 hours
  statistic           = "Maximum"
  threshold           = 5368709120  # 5GB

  dimensions = {
    BucketName = var.s3_bucket_names[count.index]
    StorageType = "StandardStorage"
  }

  alarm_description = "S3 bucket ${var.s3_bucket_names[count.index]} size is growing large"
  alarm_actions     = var.notification_email != null ? [aws_sns_topic.monitoring_alerts[0].arn] : []
}
