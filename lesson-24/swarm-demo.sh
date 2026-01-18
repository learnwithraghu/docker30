#!/bin/bash
# Docker Swarm basics demo

echo "=== Docker Swarm Demo ==="

# Initialize swarm (if not already)
echo "Initializing swarm..."
docker swarm init 2>/dev/null || echo "Swarm already initialized"

# Create service
echo "Creating service..."
docker service create \
  --name demo-web \
  --replicas 2 \
  -p 8080:80 \
  nginx:alpine

# Wait a moment
sleep 3

# List services
echo "Services:"
docker service ls

# Scale service
echo "Scaling to 3 replicas..."
docker service scale demo-web=3

# Wait
sleep 2

# Show tasks
echo "Tasks:"
docker service ps demo-web

# Clean up
echo "Removing service..."
docker service rm demo-web
echo "Done!"
