#!/bin/bash
set -e

echo "Running BeforeInstall hook..."

# Stop the application if it's running
systemctl stop donut-app || true

# Clean up old deployment
rm -rf /home/ec2-user/app/app.py
rm -rf /home/ec2-user/app/templates
rm -rf /home/ec2-user/app/requirements.txt

echo "BeforeInstall complete."
