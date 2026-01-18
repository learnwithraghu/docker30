#!/bin/bash
# Multi-architecture build demo

echo "=== Multi-Architecture Build Demo ==="

# Create buildx builder (if not exists)
echo "Setting up buildx..."
docker buildx create --name multiarch --use 2>/dev/null || \
  docker buildx use multiarch

# Build for multiple platforms
echo "Building for multiple architectures..."
echo "Note: This requires a Dockerfile in current directory"
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t demo-app:multiarch \
  --load . 2>/dev/null || \
  echo "Note: Use --push to push to registry, or ensure Dockerfile exists"

echo "Done!"
