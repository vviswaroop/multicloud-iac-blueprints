# AWS 3-Tier Web Application Infrastructure

This example demonstrates a production-ready 3-tier web application infrastructure on AWS using Terraform. The architecture includes web servers, a Kubernetes cluster, a managed database, and supporting services with high availability, security, and monitoring capabilities.

## Architecture Overview

```
Internet Gateway
        |
Application Load Balancer (Public Subnets)
        |
Web Tier - EC2 Instances (Private Subnets)
        |
Application Tier - EKS Cluster (Private Subnets)
        |
Database Tier - RDS MySQL (Private Subnets)
```

### Components

- **Web Tier**: Apache HTTP servers running on EC2 instances behind an Application Load Balancer
- **Application Tier**: Amazon EKS cluster for containerized applications
- **Database Tier**: Amazon RDS MySQL with Multi-AZ support
- **Storage**: S3 buckets for application assets and logs
- **Security**: IAM roles, security groups, and bastion host for secure access
- **Monitoring**: CloudWatch integration for logs and metrics
- **Networking**: Multi-AZ VPC with public and private subnets

## Features

### High Availability
- Multi-AZ deployment across 2-3 availability zones
- Auto Scaling Groups for EC2 instances
- RDS Multi-AZ for database failover
- EKS managed node groups with auto-scaling

### Security
- Private subnets for application and database tiers
- Security groups with least privilege access
- IAM roles with minimal required permissions
- Bastion host for secure SSH access
- Encrypted storage (EBS volumes, RDS, S3)
- Secrets Manager for database credentials

### Monitoring & Logging
- CloudWatch agent on EC2 instances
- Application and system logs centralization
- Performance insights for RDS
- EKS control plane logging
- S3 access logging

### Cost Optimization
- Configurable instance sizes
- S3 lifecycle policies
- Optional single NAT Gateway for dev/test
- EBS GP3 volumes for better price/performance

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS Key Pair** created for EC2 access
4. **Appropriate IAM permissions** for resource creation

## Quick Start

### 1. Clone and Navigate
```bash
git clone <repository-url>
cd terraform-modules/examples/aws
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:
```hcl
# Essential configurations
aws_region    = "us-west-2"
project_name  = "myapp"
environment   = "prod"
key_pair_name = "my-key-pair"

# Network configuration
vpc_cidr = "10.0.0.0/16"
az_count = 3

# Security configuration
bastion_allowed_cidrs = ["203.0.113.0/24"]  # Your IP range
eks_public_access_cidrs = ["203.0.113.0/24"]

# Production settings
db_multi_az = true
enable_deletion_protection = true
```

### 3. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

### 4. Access Your Application
After deployment completes:
```bash
# Get the load balancer URL
terraform output application_url

# Configure kubectl for EKS
terraform output kubectl_config_command
```

## Configuration Options

### Environment Sizing

#### Development Environment
```hcl
# terraform.tfvars
environment = "dev"
single_nat_gateway = true
web_server_count = 1
web_instance_type = "t3.micro"
db_instance_class = "db.t3.micro"
db_multi_az = false
eks_node_desired_size = 1
enable_deletion_protection = false
```

#### Production Environment
```hcl
# terraform.tfvars
environment = "prod"
single_nat_gateway = false
web_server_count = 3
web_instance_type = "t3.large"
db_instance_class = "db.r6i.large"
db_multi_az = true
eks_node_desired_size = 3
enable_deletion_protection = true
```

### Security Hardening

#### Network Security
- Restrict bastion access to specific IP ranges
- Limit EKS API access cidrs
- Use private subnets for all application components

#### Access Control
- Use IAM roles instead of access keys
- Enable MFA for human users
- Implement least privilege principles

#### Data Protection
- Enable encryption at rest for all storage
- Use Secrets Manager for sensitive data
- Implement backup and recovery procedures

## Post-Deployment Tasks

### 1. Configure kubectl Access
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name myapp-prod-eks

# Verify connection
kubectl get nodes
```

### 2. Database Access
```bash
# Get database credentials from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw database_master_user_secret_arn) \
  --query SecretString --output text
```

### 3. SSH Access via Bastion
```bash
# Connect to bastion host
ssh -i ~/.ssh/my-key-pair.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Connect to web servers through bastion
ssh -i ~/.ssh/my-key-pair.pem \
  -o ProxyCommand='ssh -i ~/.ssh/my-key-pair.pem -W %h:%p ec2-user@BASTION_IP' \
  ec2-user@WEB_SERVER_PRIVATE_IP
```

### 4. Monitor Application Health
Visit: `http://YOUR_ALB_DNS_NAME/health.php`

## Customization

### Adding Custom Applications to EKS

1. **Create Kubernetes manifests** in a `k8s/` directory
2. **Deploy applications** using kubectl or Helm
3. **Configure ingress** to route traffic from ALB

### Modifying Web Server Configuration

1. **Edit** `user-data/web-server.sh` script
2. **Redeploy** instances or create new AMI
3. **Update** Auto Scaling Group launch template

### Database Schema Management

1. **Connect** to RDS using credentials from Secrets Manager
2. **Run** database migrations
3. **Configure** application connection strings

## Monitoring and Alerts

### CloudWatch Dashboards
- EC2 instance metrics (CPU, memory, disk)
- RDS performance metrics
- EKS cluster metrics
- Application Load Balancer metrics

### Recommended Alerts
- High CPU utilization (>80%)
- Low disk space (<10%)
- Database connection failures
- Load balancer target failures

### Log Analysis
- Web server access/error logs
- Application logs from EKS
- Database slow query logs
- Security audit logs

## Cost Optimization

### Development/Testing
```hcl
single_nat_gateway = true              # Save ~$45/month per AZ
web_instance_type = "t3.micro"         # ~$8.50/month vs t3.large ~$60/month
db_instance_class = "db.t3.micro"      # ~$12/month vs db.r6i.large ~$200/month
eks_node_instance_types = ["t3.small"] # Reduce EKS node costs
```

### Production Optimization
- Use Reserved Instances for predictable workloads
- Implement S3 lifecycle policies
- Enable RDS automated backups cleanup
- Monitor and right-size instances

## Troubleshooting

### Common Issues

#### Web Servers Not Healthy
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN

# Check instance logs
ssh bastion -> ssh web-server
sudo tail -f /var/log/httpd/error_log
```

#### EKS Node Issues
```bash
# Check node status
kubectl get nodes

# Check node logs
kubectl describe node NODE_NAME
```

#### Database Connection Issues
```bash
# Test database connectivity from web server
mysql -h DATABASE_ENDPOINT -u admin -p
```

### Debugging Steps

1. **Check Terraform state**: `terraform show`
2. **Review AWS CloudTrail**: For API call auditing
3. **Monitor CloudWatch Logs**: For application errors
4. **Use AWS Systems Manager**: For instance management

## Maintenance

### Regular Tasks
- **Update AMIs** and redeploy instances
- **Patch EKS cluster** and node groups
- **Review security groups** and access policies
- **Monitor costs** and optimize resources
- **Backup verification** and disaster recovery testing

### Upgrade Procedures
1. **Plan maintenance windows**
2. **Update infrastructure modules**
3. **Test in staging environment**
4. **Apply changes using blue-green deployment**
5. **Monitor application health post-upgrade**

## Security Compliance

### Best Practices Implemented
- ✅ Encryption at rest and in transit
- ✅ Network segmentation with private subnets
- ✅ Least privilege IAM policies
- ✅ Security group restrictions
- ✅ Audit logging enabled
- ✅ Secrets management integration
- ✅ Regular security updates

### Additional Recommendations
- Enable AWS Config for compliance monitoring
- Implement AWS WAF for web application protection
- Use AWS Inspector for vulnerability assessment
- Enable AWS GuardDuty for threat detection
- Implement backup and disaster recovery procedures

## Support and Contributing

For questions, issues, or contributions:

1. **Review the documentation** in each module directory
2. **Check existing issues** and troubleshooting guides
3. **Test changes** in a non-production environment
4. **Follow security best practices** when contributing

## Cost Estimation

### Monthly Cost Estimates (us-west-2)

#### Development Environment
- VPC & Networking: ~$10
- EC2 (1x t3.micro): ~$8
- RDS (db.t3.micro): ~$12
- EKS Cluster: ~$73
- S3 & Other: ~$5
- **Total: ~$108/month**

#### Production Environment  
- VPC & Networking: ~$30
- EC2 (3x t3.large): ~$180
- RDS (db.r6i.large, Multi-AZ): ~$400
- EKS Cluster + Nodes: ~$200
- S3 & Other: ~$20
- **Total: ~$830/month**

*Costs are estimates and may vary based on usage patterns and AWS pricing changes.*

## License

This example is provided under the MIT License. See LICENSE file for details.