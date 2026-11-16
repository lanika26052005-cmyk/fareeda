
#!/bin/bash

set -euo pipefail

# =========================
# Configuration
# =========================

APP_NAME="fareeda-frontend"
IMAGE_NAME="fareeda-frontend"
IMAGE_TAG="latest"
CONTAINER_NAME="fareeda-frontend-app"

BRANCH="${BRANCH:-main}"
HOST_PORT="${HOST_PORT:-3000}"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

cd "$(dirname "$0")"

# =========================
# GitHub Token
# =========================

if [ -z "${GIT_TOKEN:-}" ]; then
    read -rsp "Enter GitHub Token: " GIT_TOKEN
    echo
fi

if [ -z "$GIT_TOKEN" ]; then
    echo "ERROR: GitHub token required"
    exit 1
fi

# =========================
# Backup Old Image
# =========================

if docker image inspect "$IMAGE_NAME:$IMAGE_TAG" >/dev/null 2>&1; then

    echo "Backing up old image..."

    docker tag "$IMAGE_NAME:$IMAGE_TAG" \
        "$IMAGE_NAME:backup-$TIMESTAMP"
fi

# =========================
# Build Docker Image
# =========================

echo "Building Docker image..."

docker build \
    --build-arg BRANCH="$BRANCH" \
    --build-arg GIT_TOKEN="$GIT_TOKEN" \
    -t "$IMAGE_NAME:$IMAGE_TAG" .

# =========================
# Stop Old Container
# =========================

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then

    echo "Stopping old container..."

    docker stop "$CONTAINER_NAME" || true
    docker rm "$CONTAINER_NAME" || true
fi

# =========================
# Run New Container
# =========================

echo "Deploying new container..."

docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p "$HOST_PORT:3000" \
    "$IMAGE_NAME:$IMAGE_TAG"

# =========================
# Deployment Status
# =========================

docker ps --filter "name=$CONTAINER_NAME"

echo "Fareeda Frontend Deployment Completed!"
