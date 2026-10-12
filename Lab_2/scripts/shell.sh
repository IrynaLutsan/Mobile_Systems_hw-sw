#!/usr/bin/env bash
# Інтерактивний термінал у контейнері (середовище ROS 2 підключається автоматично).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    compose up -d
fi
docker exec -it "$CONTAINER" bash
