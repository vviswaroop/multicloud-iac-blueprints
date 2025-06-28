#!/bin/bash
# Web Server Initialization Script
# This script sets up the web server with basic security and monitoring

set -e

# Update system packages
apt-get update && apt-get upgrade -y

# Install required packages
apt-get install -y \
    nginx \
    curl \
    wget \
    unzip \
    jq \
    htop \
    net-tools \
    ufw \
    fail2ban \
    logrotate

# Configure firewall
ufw --force enable
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow from 10.0.0.0/16 to any port 22

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Configure Nginx
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Enterprise Application - Web Tier</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f4; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { color: #0078d4; border-bottom: 2px solid #0078d4; padding-bottom: 10px; }
        .status { color: #107c10; font-weight: bold; }
        .info { margin: 20px 0; padding: 15px; background: #e6f3ff; border-left: 4px solid #0078d4; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">Enterprise Application</h1>
        <p class="status">✓ Web Tier is running successfully</p>
        <div class="info">
            <h3>Architecture Overview</h3>
            <ul>
                <li>Web Tier: Nginx reverse proxy and static content</li>
                <li>Application Tier: Business logic and APIs</li>
                <li>Data Tier: Azure SQL Database</li>
                <li>Container Tier: AKS cluster for microservices</li>
            </ul>
        </div>
        <p><strong>Server:</strong> <span id="hostname">Loading...</span></p>
        <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
    </div>
    
    <script>
        document.getElementById('hostname').textContent = window.location.hostname;
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF

# Configure Nginx for reverse proxy
cat > /etc/nginx/sites-available/app << 'EOF'
upstream app_backend {
    server 10.0.2.4:8080;  # Application server
    keepalive 32;
}

server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Static content
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://app_backend/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t && systemctl reload nginx

# Install and configure Azure Monitor Agent (if needed)
if command -v az &> /dev/null; then
    echo "Azure CLI installed successfully"
    # Configure managed identity authentication
    az login --identity 2>/dev/null || echo "Managed identity not yet configured"
fi

# Configure log rotation for application logs
cat > /etc/logrotate.d/webapp << 'EOF'
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload nginx
    endscript
}
EOF

# Set up basic monitoring script
cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash
# Basic health check script

LOG_FILE="/var/log/health-check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Check Nginx status
if systemctl is-active --quiet nginx; then
    NGINX_STATUS="OK"
else
    NGINX_STATUS="FAILED"
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    DISK_STATUS="OK"
else
    DISK_STATUS="WARNING"
fi

# Check memory usage
MEM_USAGE=$(free | awk 'FNR==2{printf "%.0f", $3/($3+$4)*100}')
if [ "$MEM_USAGE" -lt 80 ]; then
    MEM_STATUS="OK"
else
    MEM_STATUS="WARNING"
fi

# Log results
echo "[$TIMESTAMP] Nginx: $NGINX_STATUS, Disk: $DISK_STATUS ($DISK_USAGE%), Memory: $MEM_STATUS ($MEM_USAGE%)" >> $LOG_FILE

# Optional: Send metrics to Azure Monitor (requires configuration)
# az monitor metrics put-data --resource-id ... --metric-data ...
EOF

chmod +x /usr/local/bin/health-check.sh

# Add health check to cron (every 5 minutes)
echo "*/5 * * * * root /usr/local/bin/health-check.sh" >> /etc/crontab

# Configure fail2ban for SSH protection
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF

# Start and enable services
systemctl enable nginx
systemctl enable fail2ban
systemctl start fail2ban
systemctl restart nginx

# Create application user
useradd -m -s /bin/bash webapp
usermod -aG sudo webapp

# Set up log aggregation for Azure Monitor
mkdir -p /var/log/webapp
chown webapp:webapp /var/log/webapp

echo "Web server initialization completed successfully" >> /var/log/webapp/init.log
echo "$(date): Web tier initialization completed" | logger -t webapp-init