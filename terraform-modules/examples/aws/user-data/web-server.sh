#!/bin/bash

# Update system packages
yum update -y

# Install required packages
yum install -y httpd mysql php php-mysql aws-cli amazon-cloudwatch-agent

# Install PHP extensions for web application
yum install -y php-gd php-curl php-mbstring php-xml php-zip

# Configure Apache
systemctl enable httpd
systemctl start httpd

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/httpd/access",
                        "log_stream_name": "{instance_id}",
                        "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log", 
                        "log_group_name": "/aws/ec2/httpd/error",
                        "log_stream_name": "{instance_id}",
                        "timestamp_format": "%a %b %d %H:%M:%S.%f %Y"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "WebApp/${environment}",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait", 
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create a simple health check page
cat > /var/www/html/health.php << 'EOF'
<?php
header('Content-Type: application/json');

$health = array(
    'status' => 'healthy',
    'timestamp' => date('c'),
    'server' => gethostname(),
    'checks' => array()
);

// Check database connectivity
$db_host = "${db_endpoint}";
if (!empty($db_host)) {
    $db_parts = explode(':', $db_host);
    $db_hostname = $db_parts[0];
    $db_port = isset($db_parts[1]) ? $db_parts[1] : 3306;
    
    $connection = @fsockopen($db_hostname, $db_port, $errno, $errstr, 5);
    if ($connection) {
        $health['checks']['database'] = 'connected';
        fclose($connection);
    } else {
        $health['checks']['database'] = 'failed';
        $health['status'] = 'unhealthy';
    }
} else {
    $health['checks']['database'] = 'not_configured';
}

// Check S3 bucket accessibility
$s3_bucket = "${s3_bucket}";
if (!empty($s3_bucket)) {
    $command = "aws s3 ls s3://$s3_bucket --region " . file_get_contents('http://169.254.169.254/latest/meta-data/placement/region') . " 2>&1";
    $output = shell_exec($command);
    if (strpos($output, 'error') === false && strpos($output, 'NoSuchBucket') === false) {
        $health['checks']['s3'] = 'accessible';
    } else {
        $health['checks']['s3'] = 'failed';
        $health['status'] = 'unhealthy';
    }
} else {
    $health['checks']['s3'] = 'not_configured';
}

// Check disk space
$disk_usage = disk_free_space('/') / disk_total_space('/') * 100;
if ($disk_usage > 10) {
    $health['checks']['disk'] = 'ok';
} else {
    $health['checks']['disk'] = 'low_space';
    $health['status'] = 'warning';
}

echo json_encode($health, JSON_PRETTY_PRINT);
?>
EOF

# Create a simple index page
cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier Web Application</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .info-box { background: #e9ecef; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .status { padding: 10px; border-radius: 5px; margin: 10px 0; }
        .healthy { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .warning { background-color: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">3-Tier Web Application</h1>
        
        <div class="info-box">
            <h3>Server Information</h3>
            <p><strong>Server:</strong> <?php echo gethostname(); ?></p>
            <p><strong>IP Address:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?></p>
            <p><strong>Timestamp:</strong> <?php echo date('Y-m-d H:i:s T'); ?></p>
            <p><strong>Environment:</strong> ${environment}</p>
        </div>

        <div class="info-box">
            <h3>Application Health</h3>
            <?php
            $health_check = file_get_contents('http://localhost/health.php');
            $health_data = json_decode($health_check, true);
            
            $status_class = 'healthy';
            if ($health_data['status'] == 'warning') $status_class = 'warning';
            if ($health_data['status'] == 'unhealthy') $status_class = 'error';
            ?>
            
            <div class="status <?php echo $status_class; ?>">
                <strong>Overall Status:</strong> <?php echo strtoupper($health_data['status']); ?>
            </div>
            
            <ul>
                <?php foreach ($health_data['checks'] as $check => $result): ?>
                <li><strong><?php echo ucfirst($check); ?>:</strong> <?php echo $result; ?></li>
                <?php endforeach; ?>
            </ul>
        </div>

        <div class="info-box">
            <h3>Architecture Components</h3>
            <ul>
                <li><strong>Web Tier:</strong> Apache HTTP Server with PHP</li>
                <li><strong>Application Tier:</strong> Amazon EKS (Kubernetes)</li>
                <li><strong>Database Tier:</strong> Amazon RDS MySQL</li>
                <li><strong>Storage:</strong> Amazon S3</li>
                <li><strong>Load Balancer:</strong> Application Load Balancer</li>
                <li><strong>Monitoring:</strong> CloudWatch</li>
            </ul>
        </div>

        <div class="info-box">
            <h3>Quick Links</h3>
            <ul>
                <li><a href="/health.php">Health Check API</a></li>
                <li><a href="/phpinfo.php">PHP Info</a> (if enabled)</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

# Create PHP info page (commented out for security in production)
# cat > /var/www/html/phpinfo.php << 'EOF'
# <?php phpinfo(); ?>
# EOF

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod -R 644 /var/www/html/*

# Configure Apache to use index.php as default
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' /etc/httpd/conf/httpd.conf

# Restart Apache
systemctl restart httpd

# Configure automatic security updates
echo "0 3 * * * root yum update -y --security" >> /etc/crontab

# Configure log rotation for application logs
cat > /etc/logrotate.d/webapp << 'EOF'
/var/log/webapp/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 apache apache
    postrotate
        systemctl reload httpd > /dev/null 2>&1 || true
    endscript
}
EOF

# Create log directory
mkdir -p /var/log/webapp
chown apache:apache /var/log/webapp

# Signal that user data script has completed
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource AutoScalingGroup --region ${AWS::Region} || true

echo "Web server setup completed successfully" >> /var/log/user-data.log