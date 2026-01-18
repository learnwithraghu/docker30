#!/bin/bash
# Monitoring demonstration

echo "=== Monitoring Demo ==="

# Start container
echo "Starting container..."
docker run -d --name monitor-demo nginx:alpine

# Wait a moment
sleep 2

# Show stats
echo "Container stats:"
docker stats --no-stream monitor-demo

# Show logs
echo "Recent logs:"
docker logs --tail 10 monitor-demo

# Show resource usage
echo "Resource usage summary:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" monitor-demo

# Clean up
docker stop monitor-demo
docker rm monitor-demo
echo "Done!"
