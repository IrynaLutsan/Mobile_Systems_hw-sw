# Лабораторна робота №2: Gazebo + ArduPilot SITL + ROS 2

Середовище розгорнуте в Docker, бо ROS 2 Humble потребує Ubuntu 22.04.

| Компонент | Версія |
|---|---|
| Образ | Ubuntu 22.04.5 LTS (`osrf/ros:humble-desktop`) |
| ROS 2 | Humble |
| Gazebo Sim | Harmonic (gz-sim 8.15.0) |
| ArduPilot SITL | гілка `master`, зібраний з DDS у `/opt/ardu_ws` |
| Python | 3.10.12 |

## Структура

```
docker/Dockerfile          образ: цілі linux (GPU через /dev/dri) та mac (noVNC)
docker-compose.yml         запуск на Linux
docker-compose.mac.yml     запуск на macOS
scripts/                   автоматизація (див. нижче)
fpv_labs/src/fpv_lab2/     ROS 2 пакет; flight_test — початковий приклад з методички
logs/                      журнали симуляції та вузлів
```

## Скрипти

| Скрипт | Призначення |
|---|---|
| `scripts/build_image.sh` | зібрати Docker-образ (перший раз ~30–40 хв) |
| `scripts/start.sh [аргументи launch]` | запустити Gazebo, SITL, micro-ROS agent і дочекатися готовності до arm |
| `scripts/stop.sh` | зупинити все й видалити контейнер |
| `scripts/shell.sh` | термінал у контейнері з підключеним середовищем ROS 2 |
| `scripts/build_ws.sh` | `colcon build` пакета `fpv_lab2` |
| `scripts/run.sh [вузол]` | зібрати пакет і запустити вузол (типово `flight_test`), журнал — у `logs/` |

Скрипти самі визначають ОС і беруть потрібний compose-файл.

## Запуск

```bash
scripts/build_image.sh          # один раз
scripts/start.sh rviz:=false    # без rviz:=false відкриється ще й RViz
scripts/run.sh flight_test      # зліт на 2 м, зависання 30 с, посадка
scripts/stop.sh
```

Перевірка вручну в `scripts/shell.sh`:

```bash
ros2 node list
ros2 topic list            # /ap/v1/status, /odometry, ...
ros2 service list | grep /ap/
ros2 topic echo --once /odometry --field pose.pose.position
```

## macOS

На MacBook образ треба зібрати на самому Mac (`scripts/build_image.sh`), він
збереться під архітектуру процесора. Вікно Gazebo відкривається в браузері:
<http://localhost:6080/vnc.html?autoconnect=1&resize=remote>

Рендеринг там програмний (у Docker Desktop немає доступу до GPU), тому
виділіть Docker Desktop щонайменше 4 ядра і 8 ГБ пам'яті.

## Відомі особливості

- Linux: OpenGL у контейнері працює через Zink (Vulkan) і Mesa 25 з PPA `kisak/turtle`.
  Зі штатною Mesa 23.2 немає драйвера для Intel Lunar Lake, а з драйвером `iris`
  вікно Gazebo падає під XWayland.
- Одразу після старту ArduPilot відхиляє arm («Need Alt Estimate»), поки EKF не
  перейде на GPS; `start.sh` чекає цього сам. Початковий приклад при відмові
  завершується з помилкою, а не повторює спробу.
- `start.sh` завжди починає з чистого контейнера, тому «залишкових» процесів
  Gazebo/SITL після попереднього запуску не буває.
- Службові файли SITL (eeprom, tlog, dataflash) лежать у `.sitl/`.
