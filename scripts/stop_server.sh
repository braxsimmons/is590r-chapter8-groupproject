#!/bin/bash

echo "Running ApplicationStop hook..."

# Stop the application if it's running
if systemctl is-active --quiet donut-app; then
    systemctl stop donut-app
    echo "Application stopped."
else
    echo "Application was not running."
fi

echo "ApplicationStop complete."
