#!/bin/bash
set -e

# Log output for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting instance setup..."

# Update system packages
dnf update -y

# Install required packages
dnf install -y python3.11 python3.11-pip ruby wget

# Create application directory
mkdir -p /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/app

# Install CodeDeploy agent
cd /home/ec2-user
wget https://aws-codedeploy-${region}.s3.${region}.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Create environment file for the application
cat > /home/ec2-user/app/.env << 'ENVFILE'
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
SECRET_KEY=$(openssl rand -hex 32)
ENVFILE

chown ec2-user:ec2-user /home/ec2-user/app/.env
chmod 600 /home/ec2-user/app/.env

# Create systemd service file for the Flask app
cat > /etc/systemd/system/donut-app.service << 'SERVICEFILE'
[Unit]
Description=Donut Flavors Flask Application
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/app
EnvironmentFile=/home/ec2-user/app/.env
ExecStart=/home/ec2-user/app/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEFILE

systemctl daemon-reload

echo "Instance setup complete. Waiting for CodeDeploy..."
