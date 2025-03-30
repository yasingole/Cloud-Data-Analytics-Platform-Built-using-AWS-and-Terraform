#Database subnets group
resource "aws_db_subnet_group" "main" {
  name        = var.project_name
  description = "Database subnet froup for ${var.project_name}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${var.project_name}"
  }
}
#SG for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL traffic to RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.ec2_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

#Random password for RDS
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#Storing password in ssm
resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/db/password"
  description = "Database password for ${var.project_name} RDS"
  type        = "SecureString"
  value       = random_password.db_password.result

  tags = {
    Name = "${var.project_name}-db-password"
  }
}

#Storing username in ssm
resource "aws_ssm_parameter" "db_username" {
  name        = "/${var.project_name}/${var.environment}/db/username"
  description = "Database username for ${var.project_name} RDS"
  type        = "SecureString"
  value       = var.db_username

  tags = {
    Name = "${var.project_name}-db-username"
  }
}
#Storing database name in ssm
resource "aws_ssm_parameter" "db_name" {
  name        = "/${var.project_name}/${var.environment}/db/name"
  description = "Database name for ${var.project_name} RDS instance"
  type        = "String"
  value       = var.db_name

  tags = {
    Name        = "${var.project_name}-db-name"
    Environment = var.environment
  }
}

#RDS instance
resource "aws_db_instance" "main" {
  identifier                = "${var.project_name}-${var.environment}-db"
  allocated_storage         = var.allocated_storage
  storage_type              = "gp3"
  engine                    = "mysql"
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = random_password.db_password.result
  parameter_group_name      = aws_db_parameter_group.main.name
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  backup_retention_period   = var.backup_retention_period
  multi_az                  = var.multi_az
  storage_encrypted         = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.project_name}-final-snapshot"
  deletion_protection       = var.deletion_protection

  tags = {
    Name = "${var.project_name}-db"
  }
}

#DB parameter group (RDS SQL setup)
resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-${var.environment}-parameter-group"
  family      = "mysql8.0"
  description = "Parameter group for ${var.project_name} RDS instance"

  # Recommended parameters for MySQL
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = {
    Name        = "${var.project_name}-db-parameter-group"
    Environment = var.environment
  }
}
