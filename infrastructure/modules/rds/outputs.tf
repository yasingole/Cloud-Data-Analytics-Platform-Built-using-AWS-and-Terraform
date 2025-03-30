output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "db_subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.main.arn
}

output "security_group_id" {
  description = "ID of the security group for the RDS instance"
  value       = aws_security_group.rds.id
}

output "security_group_name" {
  description = "Name of the security group for the RDS instance"
  value       = aws_security_group.rds.name
}

output "parameter_group_id" {
  description = "ID of the DB parameter group"
  value       = aws_db_parameter_group.main.id
}

output "parameter_group_arn" {
  description = "ARN of the DB parameter group"
  value       = aws_db_parameter_group.main.arn
}

output "db_name" {
  description = "Name of the database"
  value       = var.db_name
}

output "db_username" {
  description = "Username for the database"
  value       = var.db_username
}

output "ssm_parameter_db_password" {
  description = "SSM parameter name for the database password"
  value       = aws_ssm_parameter.db_password.name
}

output "ssm_parameter_db_username" {
  description = "SSM parameter name for the database username"
  value       = aws_ssm_parameter.db_username.name
}

output "ssm_parameter_db_name" {
  description = "SSM parameter name for the database name"
  value       = aws_ssm_parameter.db_name.name
}
