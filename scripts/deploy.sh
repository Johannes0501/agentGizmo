#!/bin/bash
# Deploy script for Agent Gizmo
# Usage: ./scripts/deploy.sh [tag]

set -e

cd /home/jh/development/jarvis

echo "==> Fetching latest changes..."
git fetch --all --tags

# If a tag is provided, checkout that tag
if [ -n "$1" ]; then
    echo "==> Checking out tag: $1"
    git checkout "$1"
else
    echo "==> Pulling latest from main..."
    git checkout main
    git pull origin main
fi

echo "==> Pulling latest Docker images..."
sudo docker compose pull agent-zero

echo "==> Restarting services..."
sudo docker compose up -d agent-zero

echo "==> Current status:"
sudo docker compose ps

echo "==> Deployment complete!"
