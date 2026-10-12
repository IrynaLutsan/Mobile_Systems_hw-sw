#!/usr/bin/env bash
# Запуск симуляційного середовища: Gazebo + ArduPilot SITL + micro-ROS agent.
# Використання: scripts/start.sh [додаткові аргументи ros2 launch]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

LAUNCH_FILE="${LAUNCH_FILE:-iris_maze.launch.py}"
LOG_FILE="logs/sim_$(date +%Y%m%d_%H%M%S).log"

# Попередні процеси Gazebo, SITL і ROS 2 займають порти, тому починаємо з чистого контейнера
compose down --remove-orphans >/dev/null 2>&1 || true
compose up -d

mkdir -p "$LAB_DIR/logs"
# SITL пише eeprom.bin, mav.tlog, logs/*.BIN у поточний каталог — тримаємо їх у .sitl/
docker exec -d "$CONTAINER" bash -c \
    "source ~/.bashrc_lab && mkdir -p /workspace/.sitl && cd /workspace/.sitl && ros2 launch ardupilot_gz_bringup $LAUNCH_FILE $* > /workspace/$LOG_FILE 2>&1"
echo "Симуляцію запущено, журнал: $LOG_FILE"

wait_for() {
    local message="$1" command="$2"
    echo -n "$message"
    for _ in $(seq 1 60); do
        if in_container "$command" >/dev/null 2>&1; then
            echo " — готово"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    echo
    echo "Не дочекалися, перевірте журнал $LOG_FILE" >&2
    exit 1
}

wait_for "Очікування ArduPilot (тема /ap/v1/status)" \
    "timeout 5 ros2 topic echo --once /ap/v1/status"
# Одразу після старту EKF ще не готовий: pre-arm check або arm відхиляються
# ("Need Alt Estimate"), тому чекаємо переходу EKF на GPS і даємо йому стабілізуватися
wait_for "Очікування готовності EKF до arm" \
    "grep -q 'EKF3 IMU1 is using GPS' /workspace/$LOG_FILE && timeout 5 ros2 service call /ap/v1/prearm_check std_srvs/srv/Trigger | grep -q 'success=True'"
sleep 10

[ -n "$GUI_HINT" ] && echo "$GUI_HINT"
echo "Термінал у контейнері: scripts/shell.sh"
echo "Початковий приклад:    scripts/run.sh flight_test"
echo "Зупинка:               scripts/stop.sh"
