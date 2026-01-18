#!/bin/bash
# Debug container script

CONTAINER_ID=$1

if [ -z "$CONTAINER_ID" ]; then
    echo "Usage: $0 <container-id>"
    exit 1
fi

echo "=== Debugging Container: $CONTAINER_ID ==="

echo "1. Container status:"
docker ps -a | grep $CONTAINER_ID

echo ""
echo "2. Container logs:"
docker logs --tail 50 $CONTAINER_ID

echo ""
echo "3. Container inspect (State):"
docker inspect $CONTAINER_ID --format '{{json .State}}' | python3 -m json.tool 2>/dev/null || \
  docker inspect $CONTAINER_ID | grep -A 5 "State"

echo ""
echo "4. Resource usage:"
docker stats --no-stream $CONTAINER_ID

echo ""
echo "5. Network:"
docker inspect $CONTAINER_ID --format '{{range $key, $value := .NetworkSettings.Networks}}{{$key}} {{end}}'

echo ""
echo "To get shell access:"
echo "  docker exec -it $CONTAINER_ID /bin/bash"
