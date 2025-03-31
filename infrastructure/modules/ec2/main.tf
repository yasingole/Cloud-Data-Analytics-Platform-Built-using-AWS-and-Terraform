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


#Need to consider iam for s3 access, SSM, cloudwatch,

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

  user_data = base64decode(<<-EOF
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
