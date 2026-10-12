#!/usr/bin/env bash
# Складання робочого простору fpv_labs (пакет fpv_lab2).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    compose up -d
fi
in_container "cd /workspace/fpv_labs && colcon build --symlink-install --packages-select fpv_lab2"
