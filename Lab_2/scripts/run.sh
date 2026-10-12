#!/usr/bin/env bash
# Складання пакета та запуск вузла з fpv_lab2; журнал зберігається в logs/.
# Використання: scripts/run.sh [назва_вузла]   (типово flight_test)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

NODE="${1:-flight_test}"
LOG_FILE="$LAB_DIR/logs/${NODE}_$(date +%Y%m%d_%H%M%S).log"

"$LAB_DIR/scripts/build_ws.sh"
docker exec -t "$CONTAINER" bash -c \
    "source ~/.bashrc_lab && ros2 run fpv_lab2 $NODE" | tee "$LOG_FILE"
echo "Журнал: $LOG_FILE"
