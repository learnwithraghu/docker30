#!/bin/bash
# Tagging demonstration

echo "=== Tagging Demo ==="

# Build image (or use existing)
echo "Using nginx as example..."
docker pull nginx:alpine 2>/dev/null

# Tag with version
echo "Tagging with version..."
docker tag nginx:alpine my-app:v1.0.0
docker tag nginx:alpine my-app:v1.0
docker tag nginx:alpine my-app:v1

# Tag for environment
echo "Tagging for environments..."
docker tag nginx:alpine my-app:dev
docker tag nginx:alpine my-app:staging

# Show all tags
echo "All tags:"
docker images my-app

# Clean up (remove tags)
echo "Cleaning up..."
docker rmi my-app:v1.0.0 my-app:v1.0 my-app:v1 my-app:dev my-app:staging 2>/dev/null
echo "Done!"
