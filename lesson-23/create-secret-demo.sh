#!/bin/bash
# Secrets management demo

echo "=== Secrets Management Demo ==="

# Create secret file for Compose
echo "my-secret-value" > secret.txt
echo "Created secret.txt for Docker Compose"

echo ""
echo "For Docker Swarm:"
echo "1. Initialize swarm: docker swarm init"
echo "2. Create secret: echo 'secret' | docker secret create my_secret -"
echo "3. Use in service with secrets: - my_secret"

echo ""
echo "For Docker Compose:"
echo "1. Create secret file"
echo "2. Reference in docker-compose.yml"
echo "3. Access in container at /run/secrets/<name>"

# Clean up
# rm -f secret.txt
echo "Done! (secret.txt kept for testing)"
