#!/bin/bash
# Advanced networking demo

echo "=== Advanced Networking Demo ==="

# Create custom bridge
echo "Creating custom bridge network..."
docker network create \
  --driver bridge \
  --subnet=172.25.0.0/16 \
  custom-bridge

# Run containers
echo "Starting containers..."
docker run -d --network custom-bridge --name net-app1 nginx:alpine
docker run -d --network custom-bridge --name net-app2 nginx:alpine

# Test connectivity
echo "Testing connectivity..."
docker exec net-app1 ping -c 3 net-app2

# Inspect network
echo "Network details:"
docker network inspect custom-bridge --format '{{range .Containers}}{{.Name}} {{end}}'

# Clean up
docker stop net-app1 net-app2
docker rm net-app1 net-app2
docker network rm custom-bridge
echo "Done!"
