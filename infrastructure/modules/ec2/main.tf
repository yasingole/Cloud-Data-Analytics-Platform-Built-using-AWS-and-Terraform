#SG for ec2

#IAM role for ec2 instances

#IAM profile for attachment

#Data for amazon linux 2

#Launch template
/* The AMI to use (operating system)
Instance type (CPU, memory, etc.)
Security groups (firewall rules)
IAM role (permissions)
Storage configuration (encrypted root volume)
User data script (bootstrap commands run at instance startup)
*/

#ASG

/*
User data advice:
1. Package Installation

AWS CLI: Necessary for interacting with AWS services programmatically
CloudWatch Agent: Enables metrics collection and log streaming to CloudWatch
Python Libraries: Tools like pandas and scikit-learn are essential for healthcare data analysis
MySQL Client: Needed to connect to your RDS database

2. CloudWatch Agent Configuration

Metrics Collection: Monitors system health (CPU, memory, disk usage)
Log Collection: Centralizes logs in CloudWatch for easier troubleshooting
Retention Policy: Controls how long logs are kept to manage costs

3. Data Processing Script

Database Connection: Uses SSM Parameter Store for secure credential management
S3 Interaction: Retrieves raw data and stores processed results
Error Handling: Logs issues to help with troubleshooting
Database Loading: Populates RDS with processed healthcare data
File Management: Organizes files in S3 to prevent reprocessing

4. Automation

Cron Job: Schedules regular data processing
Script Permissions: Ensures the script can be executed

5. Instance Identification

Metadata Retrieval: Gets instance identity information
Tagging: Labels resources for better management and cost tracking
*/
