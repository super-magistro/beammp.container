#!/bin/bash

# Load environment variables from the .env file
source .env

# Check if the PORT variable is defined
if [ -z "$PORT" ]; then
  echo "[ERROR] PORT variable is not defined in the .env file"
  exit 1
fi

# Path to the docker-compose file
COMPOSE_FILE="docker-compose.yml"

# Create a backup of the original file
cp "$COMPOSE_FILE" "$COMPOSE_FILE.bak"

# Use sed to remove the 'ports:' line and all following lines until 'environment:'
sed -i '/^\s*ports:/,/^\s*environment:/d' "$COMPOSE_FILE"

# Dynamically insert the ports block just before the environment section
sed -i "/^\s*environment:/i \    ports:\n      - \"${PORT}:${PORT}/tcp\"\n      - \"${PORT}:${PORT}/udp\"" "$COMPOSE_FILE"

# Rebuild the Docker image without cache
docker compose build --no-cache

echo "[Info] docker-compose.yml updated with port $PORT and image rebuilt."
