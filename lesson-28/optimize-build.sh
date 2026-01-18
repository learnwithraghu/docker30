#!/bin/bash
# Build optimization demo

echo "=== Build Optimization Demo ==="

# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with cache
echo "Building with cache..."
time docker build -t optimized-app . 2>/dev/null || \
  echo "Note: Requires Dockerfile in current directory"

# Show image size
echo "Image size:"
docker images optimized-app --format "{{.Size}}" 2>/dev/null || \
  echo "Image not built"

echo "Done!"
