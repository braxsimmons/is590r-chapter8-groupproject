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

# Set proper ownership
chown -R ec2-user:ec2-user $APP_DIR

echo "AfterInstall complete."
