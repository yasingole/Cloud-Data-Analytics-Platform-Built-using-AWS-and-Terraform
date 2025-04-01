#SG for ec2
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "SG for data processing instances"
  vpc_id      = var.vpc_id

  #Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound connections"
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}
#IAM role for ec2 instances
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
  }
}

#SSM
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#IAM profile for attachment
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

#Data for amazon linux 2
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
#Latest AMI for amazon linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Launch template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Install minimum requirements for Ansible
    yum update -y
    yum install -y python3 amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Tag instance
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

    echo "Prepared for Ansible management" > /var/log/user-data-complete.log
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-data-processor"
      Environment = var.environment
    }
  }
}

#ASG
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-data-processor"
    propagate_at_launch = true
  }

  tag {
    key                 = "AnsibleGroup"
    value               = "processors"
    propagate_at_launch = true
  }
}

#IAM
#S3 access policy
resource "aws_iam_policy" "ec2_s3_access" {
  name        = "${var.project_name}-${var.environment}-ec2-s3-access"
  description = "Policy for EC2 instances to access S3 buckets"

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

#CloudWatch Logs policy
resource "aws_iam_policy" "ec2_cloudwatch_logs" {
  name        = "${var.project_name}-${var.environment}-ec2-cloudwatch-logs"
  description = "Policy for EC2 instances to write CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:/aws/ec2/${var.project_name}-*"
      }
    ]
  })
}

#CloudWatch Metrics policy
resource "aws_iam_policy" "ec2_cloudwatch_metrics" {
  name        = "${var.project_name}-${var.environment}-ec2-cloudwatch-metrics"
  description = "Policy for EC2 instances to write CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

#SSM Parameter Store policy
resource "aws_iam_policy" "ec2_ssm_parameters" {
  name        = "${var.project_name}-${var.environment}-ec2-ssm-parameters"
  description = "Policy for EC2 instances to access SSM parameters"

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

#Attach policies to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_logs" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_logs.arn
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_metrics" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_metrics.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_parameters" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_ssm_parameters.arn
}
