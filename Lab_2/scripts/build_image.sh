#!/usr/bin/env bash
# Збирання Docker-образу з ROS 2 Humble, Gazebo Harmonic та ArduPilot SITL.
# Перше збирання триває довго (завантаження і компіляція ArduPilot).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

compose build "$@"
