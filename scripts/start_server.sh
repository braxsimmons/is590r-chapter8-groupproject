#!/bin/bash
set -e

echo "Running ApplicationStart hook..."

# Enable and start the Flask application service
systemctl daemon-reload
systemctl enable donut-app
systemctl start donut-app

# Wait for the service to start
sleep 5

# Check if service is running
if systemctl is-active --quiet donut-app; then
    echo "Application started successfully!"
else
    echo "Failed to start application!"
    systemctl status donut-app
    exit 1
fi

echo "ApplicationStart complete."
