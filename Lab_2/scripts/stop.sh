#!/usr/bin/env bash
# Зупинка середовища: завершує Gazebo, SITL, micro-ROS agent і видаляє контейнер.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

compose down --remove-orphans
