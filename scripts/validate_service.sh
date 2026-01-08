#!/bin/bash
set -e

echo "Running ValidateService hook..."

# Wait for application to be fully ready
sleep 10

# Check if the service is running
if ! systemctl is-active --quiet donut-app; then
    echo "ERROR: donut-app service is not running!"
    exit 1
fi

# Health check - verify the application responds
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health || echo "000")

if [ "$HEALTH_CHECK" == "200" ]; then
    echo "Health check passed! Application is responding."
else
    echo "ERROR: Health check failed with status code: $HEALTH_CHECK"
    exit 1
fi

echo "ValidateService complete. Deployment successful!"
