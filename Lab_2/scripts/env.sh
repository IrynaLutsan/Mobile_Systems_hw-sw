#!/usr/bin/env bash
# Спільні налаштування для всіх скриптів. Підключається через `source`.
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export LAB_DIR

CONTAINER=fpv_lab2

if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: GUI через noVNC у браузері, без GPU та X11 хоста
    COMPOSE_FILE="$LAB_DIR/docker-compose.mac.yml"
    GUI_HINT="Вікно Gazebo: http://localhost:6080/vnc.html?autoconnect=1&resize=remote"
else
    COMPOSE_FILE="$LAB_DIR/docker-compose.yml"
    GUI_HINT=""
    export HOST_UID="$(id -u)"
    export HOST_GID="$(id -g)"
    export RENDER_GID="$(getent group render | cut -d: -f3)"
    export VIDEO_GID="$(getent group video | cut -d: -f3)"
    export DISPLAY="${DISPLAY:-:0}"
    export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
fi

compose() {
    docker compose -f "$COMPOSE_FILE" "$@"
}

# Виконати команду в контейнері з підключеним середовищем ROS 2
in_container() {
    docker exec "$CONTAINER" bash -c "source ~/.bashrc_lab && $*"
}
