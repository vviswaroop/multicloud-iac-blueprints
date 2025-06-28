# GCP Microservices Platform - Terraform Example

This example demonstrates how to deploy a production-ready microservices platform on Google Cloud Platform (GCP) using the Terraform modules in this repository. The architecture includes a private GKE cluster, Cloud SQL PostgreSQL database, secure networking, and comprehensive IAM setup.

## Architecture Overview

The deployed infrastructure includes:

- **VPC Network** with multiple subnets for different tiers
- **GKE Cluster** (private) with multiple node pools for different workload types
- **Cloud SQL PostgreSQL** with read replicas and automated backups
- **Cloud Storage** buckets for application data and backups
- **IAM Service Accounts** with least-privilege permissions
- **Bastion Host** for secure management access
- **Comprehensive Security** with network policies, private clusters, and workload identity

## Infrastructure Components

### Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ VPC Network (10.0.0.0/16)                                      │
│                                                                 │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │
│ │ GKE Subnet      │ │ Private Subnet  │ │ Management      │   │
│ │ 10.0.1.0/24     │ │ 10.0.2.0/24     │ │ Subnet          │   │
│ │                 │ │                 │ │ 10.0.3.0/24     │   │
│ │ ┌─────────────┐ │ │ ┌─────────────┐ │ │ ┌─────────────┐ │   │
│ │ │ GKE Cluster │ │ │ │ Cloud SQL   │ │ │ │ Bastion     │ │   │
│ │ │ (Private)   │ │ │ │ (Private)   │ │ │ │ Host        │ │   │
│ │ └─────────────┘ │ │ └─────────────┘ │ │ └─────────────┘ │   │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘   │
│                                                                 │
│ Secondary Ranges:                                               │
│ • Pods: 10.1.0.0/16                                           │
│ • Services: 10.2.0.0/16                                       │
└─────────────────────────────────────────────────────────────────┘
```

### GKE Cluster Configuration

- **Cluster Type**: Regional private cluster with Workload Identity
- **Node Pools**:
  - **General**: e2-standard-4 instances for most workloads
  - **High-Memory**: n2-highmem-4 instances for memory-intensive applications
- **Networking**: Uses VPC-native networking with secondary ranges
- **Security**: Network policies, Binary Authorization (prod), private nodes
- **Autoscaling**: Cluster and node pool autoscaling enabled

### Database Setup

- **Cloud SQL PostgreSQL 15** with private IP
- **Multiple Databases**: 
  - `users_service`
  - `orders_service`
  - `inventory_service`
  - `payments_service`
  - `notifications_service`
- **Backup Strategy**: Automated daily backups with point-in-time recovery
- **High Availability**: Regional configuration for production environments

## Prerequisites

1. **GCP Project** with billing enabled
2. **Terraform** >= 1.0 installed
3. **Google Cloud SDK** installed and authenticated
4. Required **GCP APIs** enabled:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable storage.googleapis.com
   gcloud services enable iam.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   gcloud services enable servicenetworking.googleapis.com
   ```

5. **IAM Permissions** for the deploying user:
   - Project Editor or custom role with necessary permissions
   - Service Account Admin
   - Security Admin

## Quick Start

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd terraform-modules/examples/gcp
```

### 2. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your specific values
nano terraform.tfvars
```

### 3. Set Sensitive Variables

Instead of putting sensitive values in `terraform.tfvars`, use environment variables:

```bash
export TF_VAR_project_id="your-gcp-project-id"
export TF_VAR_db_backend_password="your-secure-password-123!"
export TF_VAR_db_readonly_password="your-readonly-password-456!"
```

### 4. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 5. Connect to Your Infrastructure

After deployment, use the output commands to connect:

```bash
# Configure kubectl
$(terraform output -raw gke_get_credentials_command)

# SSH to bastion host
$(terraform output -raw bastion_ssh_command)

# Connect to Cloud SQL via proxy
$(terraform output -raw cloudsql_proxy_command)
```

## Configuration Examples

### Development Environment

```hcl
# terraform.tfvars
environment                = "dev"
gke_node_count            = 1
gke_machine_type          = "e2-standard-2"
cloudsql_tier             = "db-custom-1-4096"
enable_preemptible_nodes  = true
backup_retention_days     = 7
enable_binary_authorization = false
```

### Production Environment

```hcl
# terraform.tfvars
environment                = "prod"
gke_node_count            = 3
gke_machine_type          = "e2-standard-8"
cloudsql_tier             = "db-custom-4-16384"
enable_preemptible_nodes  = false
backup_retention_days     = 30
enable_cross_region_backup = true
enable_binary_authorization = true
authorized_networks_cidr  = "203.0.113.0/24"  # Your office IP
min_node_count           = 3
max_node_count           = 20
```

## Deploying Applications

### 1. Configure kubectl

```bash
gcloud container clusters get-credentials microservices-platform-gke-dev \
  --region us-central1 --project your-project-id
```

### 2. Create Kubernetes Manifests

Example deployment for a microservice:

```yaml
# users-service-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: users-service
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: users-service
  template:
    metadata:
      labels:
        app: users-service
    spec:
      serviceAccountName: microservices-platform-app-backend-dev
      containers:
      - name: users-service
        image: gcr.io/your-project/users-service:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: "10.0.2.x"  # Cloud SQL private IP
        - name: DB_NAME
          value: "users_service"
        - name: DB_USER
          value: "app_backend_user"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
---
apiVersion: v1
kind: Service
metadata:
  name: users-service
spec:
  selector:
    app: users-service
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### 3. Database Connection

Use the Cloud SQL Proxy for database connections:

```bash
# Run Cloud SQL Proxy (from bastion or local machine)
cloud-sql-proxy your-project:us-central1:instance-name --private-ip
```

Or connect directly using the private IP from within the cluster.

## Security Best Practices

### 1. Network Security

- **Private Cluster**: All nodes have private IPs only
- **Authorized Networks**: Restrict master API access
- **Network Policies**: Control pod-to-pod communication
- **Firewall Rules**: Minimal required access

### 2. Identity and Access Management

- **Workload Identity**: Secure service account access for pods
- **Least Privilege**: Service accounts with minimal required permissions
- **Service Account Keys**: Avoid downloading keys when possible

### 3. Data Protection

- **Encryption**: All data encrypted at rest and in transit
- **Private IP**: Database accessible only via private network
- **SSL/TLS**: Required for all database connections
- **Backup Encryption**: Automated encrypted backups

### 4. Container Security

- **Binary Authorization**: Container image verification (production)
- **Vulnerability Scanning**: Automatic image vulnerability scanning
- **Security Contexts**: Non-root containers with security contexts
- **Pod Security Standards**: Enforce pod security policies

## Monitoring and Observability

### 1. Google Cloud Monitoring

Access monitoring dashboards:
- **GKE Monitoring**: [GCP Console - Kubernetes Engine](https://console.cloud.google.com/kubernetes)
- **Cloud SQL Monitoring**: [GCP Console - SQL](https://console.cloud.google.com/sql)
- **VPC Flow Logs**: [GCP Console - Logging](https://console.cloud.google.com/logs)

### 2. Application Monitoring

Deploy monitoring stack to the cluster:

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus and Grafana
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

### 3. Log Management

Configure log forwarding for applications:

```yaml
# fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      format json
    </source>
    
    <match kubernetes.**>
      @type google_cloud
      project_id "#{ENV['PROJECT_ID']}"
    </match>
```

## Backup and Disaster Recovery

### 1. Database Backups

- **Automated Backups**: Daily automated backups retained for 30 days (production)
- **Point-in-Time Recovery**: Enabled for granular recovery options
- **Cross-Region Replicas**: Available for disaster recovery
- **Manual Backups**: Create on-demand backups before major changes

### 2. Application Data Backups

```bash
# Backup Kubernetes secrets and configs
kubectl get secrets -o yaml > secrets-backup.yaml
kubectl get configmaps -o yaml > configmaps-backup.yaml

# Backup to Cloud Storage
gsutil cp secrets-backup.yaml gs://your-backup-bucket/k8s/
gsutil cp configmaps-backup.yaml gs://your-backup-bucket/k8s/
```

### 3. Infrastructure Backup

- **Terraform State**: Store in Cloud Storage with versioning
- **Infrastructure as Code**: All infrastructure defined in version control
- **Regular Testing**: Test disaster recovery procedures regularly

## Cost Optimization

### 1. Right-sizing Resources

- **Monitor Usage**: Use GCP monitoring to identify underutilized resources
- **Cluster Autoscaling**: Automatically scale nodes based on demand
- **Preemptible Nodes**: Use for non-production environments
- **Committed Use Discounts**: For predictable workloads

### 2. Storage Optimization

- **Lifecycle Policies**: Automatically transition to cheaper storage classes
- **Data Retention**: Implement appropriate retention policies
- **Compression**: Use compression for backups and archives

### 3. Network Optimization

- **Regional Resources**: Keep resources in the same region to reduce egress costs
- **Private Google Access**: Access Google APIs without external IP costs
- **Load Balancer Efficiency**: Use appropriate load balancer types

## Troubleshooting

### Common Issues and Solutions

#### 1. GKE Cluster Creation Fails

```bash
# Check quotas
gcloud compute project-info describe --project=your-project

# Verify APIs are enabled
gcloud services list --enabled --project=your-project
```

#### 2. Database Connection Issues

```bash
# Test connectivity from bastion
gcloud compute ssh bastion-instance --zone=us-central1-a
telnet CLOUD_SQL_PRIVATE_IP 5432

# Check private service connection
gcloud services vpc-peerings list --network=your-vpc
```

#### 3. Pod Scheduling Issues

```bash
# Check node resources
kubectl describe nodes

# View pod events
kubectl describe pod pod-name

# Check node pool status
kubectl get nodes -o wide
```

#### 4. Permission Issues

```bash
# Check service account permissions
gcloud projects get-iam-policy your-project

# Verify workload identity binding
kubectl describe serviceaccount service-account-name
```

## Maintenance

### Regular Maintenance Tasks

1. **Update Terraform Modules**: Keep modules updated to latest versions
2. **GKE Updates**: Regularly update cluster and node versions
3. **Security Patches**: Apply security patches to applications
4. **Certificate Rotation**: Rotate certificates and secrets regularly
5. **Access Review**: Review and audit access permissions quarterly
6. **Cost Review**: Monthly cost optimization reviews
7. **Backup Testing**: Test backup and recovery procedures monthly

### Version Upgrades

```bash
# Check available GKE versions
gcloud container get-server-config --region=us-central1

# Upgrade cluster master
gcloud container clusters upgrade cluster-name --region=us-central1

# Upgrade node pools
gcloud container clusters upgrade cluster-name --region=us-central1 --node-pool=pool-name
```

## Additional Resources

- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)
- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## Support

For issues related to this example:

1. Check the troubleshooting section above
2. Review Terraform module documentation
3. Consult GCP documentation for service-specific issues
4. Open an issue in this repository with detailed information

## License

This example is provided under the same license as the parent repository.