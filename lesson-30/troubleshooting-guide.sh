#!/bin/bash
# Troubleshooting guide

echo "=== Docker Troubleshooting Guide ==="

echo "1. Check Docker daemon:"
docker info > /dev/null 2>&1 && echo "✓ Docker is running" || echo "✗ Docker is not running"

echo ""
echo "2. Check containers:"
docker ps -a

echo ""
echo "3. Check images:"
docker images

echo ""
echo "4. Check networks:"
docker network ls

echo ""
echo "5. Check volumes:"
docker volume ls

echo ""
echo "6. System information:"
docker system df

echo ""
echo "7. Recent container logs (if any):"
docker ps -q | head -1 | xargs -I {} docker logs --tail 5 {} 2>/dev/null || echo "No running containers"

echo ""
echo "Common commands:"
echo "  - docker logs <container>"
echo "  - docker inspect <container>"
echo "  - docker exec -it <container> /bin/bash"
echo "  - docker stats"
echo "  - docker system prune"
