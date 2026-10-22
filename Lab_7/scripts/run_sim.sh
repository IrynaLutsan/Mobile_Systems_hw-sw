#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Запуск симуляційного середовища для Лабораторної №7..."

docker run -it --rm \
  --name fpv_lab7 \
  -p 14550:14550/udp \
  -v "$REPO_ROOT/Lab_7:/workspace/Lab_7" \
  fpv-lab2:humble-harmonic-mac \
  bash -c "export PATH=\$PATH:/home/ros/ardupilot/Tools/autotest; sim_vehicle.py -v ArduCopter -f gazebo-iris --model JSON --out udp:host.docker.internal:14550"