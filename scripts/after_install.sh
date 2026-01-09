#!/bin/bash
set -e

echo "Running AfterInstall hook..."

APP_DIR="/home/ec2-user/app"
cd $APP_DIR

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3.11 -m venv venv
fi

# Activate virtual environment and install dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Create environment file with database credentials
cat > /home/ec2-user/app/.env << 'ENVFILE'
DB_HOST=donut-flavors-db.corawek8w32f.us-east-1.rds.amazonaws.com
DB_NAME=donutdb
DB_USER=admin
DB_PASSWORD=Silverback2025!!
SECRET_KEY=donut-secret-key-production-2025
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

# Set proper ownership
chown -R ec2-user:ec2-user $APP_DIR

echo "AfterInstall complete."
