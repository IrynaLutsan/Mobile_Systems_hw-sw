#!/usr/bin/env bash
# Віртуальний робочий стіл для macOS: Xvnc + openbox + noVNC (порт 6080).
set -euo pipefail

GEOMETRY="${VNC_GEOMETRY:-1600x900}"

rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
Xvnc :1 -geometry "$GEOMETRY" -depth 24 -SecurityTypes None -localhost \
    -AlwaysShared >/tmp/xvnc.log 2>&1 &

for _ in $(seq 1 50); do
    [ -S /tmp/.X11-unix/X1 ] && break
    sleep 0.1
done

openbox >/tmp/openbox.log 2>&1 &
exec websockify --web /usr/share/novnc 6080 localhost:5901
