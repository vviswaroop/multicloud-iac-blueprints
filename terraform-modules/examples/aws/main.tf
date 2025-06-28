terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Data sources for availability zones and AMI
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Local values for common configurations
locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  
  common_tags = merge(var.common_tags, {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "Terraform"
    Architecture  = "3-tier-web-app"
  })
}

# VPC Module - Network Foundation
module "vpc" {
  source = "../../aws/vpc"

  name                = "${var.project_name}-${var.environment}"
  cidr_block          = var.vpc_cidr
  availability_zones  = local.availability_zones
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = local.common_tags
}

# IAM Roles and Policies
module "ec2_iam_role" {
  source = "../../aws/iam"

  name                     = "${var.project_name}-${var.environment}-ec2"
  create_role              = true
  create_instance_profile  = true
  trusted_role_services    = ["ec2.amazonaws.com"]
  
  aws_managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  
  inline_policies = {
    s3_access = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${module.app_bucket.bucket_arn}/*"
      }]
    })
  }
  
  tags = local.common_tags
}

module "eks_service_role" {
  source = "../../aws/iam"

  name                  = "${var.project_name}-${var.environment}-eks-service"
  create_role           = true
  trusted_role_services = ["eks.amazonaws.com"]
  
  aws_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
  
  tags = local.common_tags
}

# S3 Buckets for Application Assets and Logs
module "app_bucket" {
  source = "../../aws/s3"

  bucket_name         = "${var.project_name}-${var.environment}-app-${random_id.bucket_suffix.hex}"
  versioning_enabled  = true
  encryption_enabled  = true
  
  public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  
  lifecycle_rules = [{
    id     = "app_lifecycle"
    status = "Enabled"
    
    transition = [{
      days          = 30
      storage_class = "STANDARD_IA"
    }, {
      days          = 90
      storage_class = "GLACIER"
    }]
    
    noncurrent_version_expiration = {
      noncurrent_days = 30
    }
  }]
  
  cors_rules = [{
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }]
  
  tags = local.common_tags
}

module "logs_bucket" {
  source = "../../aws/s3"

  bucket_name         = "${var.project_name}-${var.environment}-logs-${random_id.bucket_suffix.hex}"
  versioning_enabled  = false
  encryption_enabled  = true
  
  lifecycle_rules = [{
    id     = "logs_lifecycle"
    status = "Enabled"
    
    expiration = {
      days = 90
    }
    
    transition = [{
      days          = 7
      storage_class = "STANDARD_IA"
    }]
  }]
  
  tags = local.common_tags
}

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = module.logs_bucket.bucket_id
    prefix  = "alb-access-logs"
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

# Target Group for Web Servers
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-${var.environment}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-tg"
  })
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = local.common_tags
}

# Web Tier - EC2 Instances
module "web_servers" {
  source = "../../aws/ec2"
  count  = var.web_server_count

  name                        = "${var.project_name}-${var.environment}-web-${count.index + 1}"
  ami_id                      = data.aws_ami.amazon_linux.id
  instance_type               = var.web_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = element(module.vpc.private_subnet_ids, count.index)
  associate_public_ip_address = false
  iam_instance_profile        = module.ec2_iam_role.instance_profile_name
  
  create_security_group = true
  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "HTTP from ALB"
    },
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "SSH from VPC"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
  
  user_data = base64encode(templatefile("${path.module}/user-data/web-server.sh", {
    db_endpoint = module.database.db_instance_endpoint
    s3_bucket   = module.app_bucket.bucket_id
    environment = var.environment
  }))
  
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }
  
  monitoring = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-${count.index + 1}"
    Tier = "Web"
  })
}

# Attach Web Servers to Target Group
resource "aws_lb_target_group_attachment" "web" {
  count            = var.web_server_count
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = module.web_servers[count.index].instance_id
  port             = 80
}

# Database Tier - RDS MySQL
module "database" {
  source = "../../aws/rds"

  name                       = "${var.project_name}-${var.environment}-db"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_allocated_storage
  max_allocated_storage      = var.db_max_allocated_storage
  storage_encrypted          = true
  
  database_name              = var.db_name
  username                   = var.db_username
  manage_master_user_password = true
  
  subnet_ids                 = module.vpc.private_subnet_ids
  vpc_security_group_ids     = [aws_security_group.database.id]
  
  backup_retention_period    = 7
  backup_window              = "03:00-04:00"
  maintenance_window         = "sun:04:00-sun:05:00"
  
  multi_az                   = var.db_multi_az
  deletion_protection        = var.enable_deletion_protection
  skip_final_snapshot        = !var.enable_deletion_protection
  final_snapshot_identifier  = var.enable_deletion_protection ? "${var.project_name}-${var.environment}-final-snapshot" : null
  
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query"]
  monitoring_interval             = 60
  performance_insights_enabled    = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-database"
    Tier = "Database"
  })
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  description = "Security group for RDS database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [for server in module.web_servers : server.security_group_id]
  }

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks_cluster.cluster_primary_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Container Orchestration Tier - EKS Cluster
module "eks_cluster" {
  source = "../../aws/eks"

  name                = "${var.project_name}-${var.environment}-eks"
  kubernetes_version  = var.kubernetes_version
  subnet_ids          = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)

  endpoint_config = {
    private_access      = true
    public_access       = true
    public_access_cidrs = var.eks_public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  node_groups = {
    main = {
      instance_types = var.eks_node_instance_types
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"
      
      scaling_config = {
        desired_size = var.eks_node_desired_size
        max_size     = var.eks_node_max_size
        min_size     = var.eks_node_min_size
      }
      
      subnet_ids = module.vpc.private_subnet_ids
      
      remote_access = var.key_pair_name != "" ? {
        ec2_ssh_key = var.key_pair_name
      } : null
      
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }
      
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${var.environment}-eks-main-nodes"
      })
    }
  }

  fargate_profiles = var.enable_fargate ? {
    default = {
      subnet_ids = module.vpc.private_subnet_ids
      
      selectors = [{
        namespace = "default"
        labels    = {}
      }, {
        namespace = "kube-system"
        labels    = {}
      }]
      
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${var.environment}-fargate-default"
      })
    }
  } : {}

  cluster_addons = {
    coredns = {
      addon_version = "v1.10.1-eksbuild.5"
    }
    kube-proxy = {
      addon_version = "v1.28.2-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.15.1-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      addon_version = "v1.24.0-eksbuild.1"
    }
  }

  enable_irsa = true

  cluster_security_group_additional_rules = {
    ingress_nodes_443 = {
      description              = "Node groups to cluster API"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = module.eks_cluster.cluster_primary_security_group_id
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
    
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks"
    Tier = "Container"
  })
}

# Bastion Host for Secure Access
module "bastion" {
  source = "../../aws/ec2"
  count  = var.create_bastion ? 1 : 0

  name                        = "${var.project_name}-${var.environment}-bastion"
  ami_id                      = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  key_name                    = var.key_pair_name
  subnet_id                   = element(module.vpc.public_subnet_ids, 0)
  associate_public_ip_address = true
  iam_instance_profile        = module.ec2_iam_role.instance_profile_name
  
  create_security_group = true
  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.bastion_allowed_cidrs
      description = "SSH access"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
  
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }
  
  monitoring = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion"
    Tier = "Management"
  })
}

# Random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}