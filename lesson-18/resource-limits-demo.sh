#!/bin/bash
# Resource limits demonstration

echo "=== Resource Limits Demo ==="

# Start with limits
echo "Starting container with resource limits..."
docker run -d \
  --name limited \
  --memory="256m" \
  --cpus="0.5" \
  nginx:alpine

# Monitor resources
echo "Resource usage:"
docker stats --no-stream limited

# Start unlimited for comparison
echo "Starting unlimited container..."
docker run -d --name unlimited nginx:alpine

# Compare
echo "Comparison:"
docker stats --no-stream limited unlimited

# Clean up
docker stop limited unlimited
docker rm limited unlimited
echo "Done!"
