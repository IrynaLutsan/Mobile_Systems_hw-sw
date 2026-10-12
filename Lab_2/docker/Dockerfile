# Лабораторна 2: ROS 2 Humble + Gazebo Harmonic + ArduPilot SITL (DDS)
# Шляхи збігаються з методичкою: /opt/ros/humble та /opt/ardu_ws
FROM osrf/ros:humble-desktop AS base

ARG USER_NAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    GZ_VERSION=harmonic \
    LANG=C.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- базові інструменти та залежності збирання ArduPilot ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl wget gnupg lsb-release software-properties-common sudo git \
        build-essential ccache gawk rsync nano less procps psmisc iproute2 \
        default-jdk \
        python3-pip python3-dev python3-vcstool python3-rosdep \
        python3-colcon-common-extensions \
        python3-empy python3-pexpect python3-future python3-lxml \
        python3-numpy python3-setuptools python3-wxgtk4.0 python3-matplotlib \
        libxml2-dev libxslt1-dev \
        mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# --- Gazebo Harmonic ---
RUN wget -q https://packages.osrfoundation.org/gazebo.gpg \
        -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/gazebo-stable.list \
    && wget -q https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list \
        -O /etc/ros/rosdep/sources.list.d/00-gazebo.list \
    && apt-get update && apt-get install -y --no-install-recommends gz-harmonic \
    && rm -rf /var/lib/apt/lists/*

# --- Python-залежності ArduPilot / MAVProxy ---
RUN pip3 install --no-cache-dir pymavlink MAVProxy dronecan

# --- Micro-XRCE-DDS-Gen (генератор DDS-типів для AP_DDS) ---
RUN git clone --recurse-submodules --depth 1 \
        https://github.com/ardupilot/Micro-XRCE-DDS-Gen.git /opt/Micro-XRCE-DDS-Gen \
    && cd /opt/Micro-XRCE-DDS-Gen && ./gradlew assemble --no-daemon \
    && rm -rf /root/.gradle
ENV PATH="${PATH}:/opt/Micro-XRCE-DDS-Gen/scripts"

# --- користувач з тим самим UID, що й на хості (права на змонтовані файли, X11) ---
RUN groupadd -g ${USER_GID} ${USER_NAME} \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} \
    && mkdir -p /opt/ardu_ws/src /workspace \
    && chown -R ${USER_NAME}:${USER_NAME} /opt/ardu_ws /workspace

USER ${USER_NAME}
WORKDIR /opt/ardu_ws

# --- вихідний код: ArduPilot, ardupilot_gazebo, ardupilot_gz, micro-ROS agent, ros_gz ---
RUN vcs import --shallow \
        --input https://raw.githubusercontent.com/ArduPilot/ardupilot_gz/main/ros2_gz.repos src

# Підмодулі тягнемо послідовно і з паузами: після серії клонувань GitHub тимчасово відмовляє
RUN for repo in src/*/; do \
        [ -f "$repo/.gitmodules" ] || continue; \
        for attempt in 1 2 3 4 5 6 7 8; do \
            git -C "$repo" submodule update --init --recursive --depth 1 --jobs 1 && break; \
            [ "$attempt" = 8 ] && exit 1; \
            sleep 60; \
        done; \
    done

RUN sudo apt-get update && rosdep update \
    && source /opt/ros/humble/setup.bash \
    && rosdep install --from-paths src --ignore-src -y -r \
    && sudo rm -rf /var/lib/apt/lists/*

# --- збирання робочого простору ArduPilot ---
RUN source /opt/ros/humble/setup.bash \
    && MAKEFLAGS="-j2" colcon build --parallel-workers 2 \
        --cmake-args -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && rm -rf log

COPY --chown=${USER_UID}:${USER_GID} bashrc_lab /home/${USER_NAME}/.bashrc_lab
RUN echo "source ~/.bashrc_lab" >> /home/${USER_NAME}/.bashrc

WORKDIR /workspace
CMD ["sleep", "infinity"]


# ============================ Linux (типова ціль) ============================
FROM base AS linux

# Новіша Mesa (25.0): у штатній Mesa 23.2 з Ubuntu 22.04 немає драйвера
# для Intel Lunar Lake, і Gazebo працював би на програмному рендерингу
USER root
RUN add-apt-repository -y ppa:kisak/turtle \
    && apt-get update && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends mesa-vulkan-drivers vulkan-tools \
    && rm -rf /var/lib/apt/lists/*
USER ${USER_NAME}


# ================================== macOS ==================================
# У Docker Desktop немає ні GPU, ні X-сервера хоста, тому Gazebo малює у
# віртуальний робочий стіл усередині контейнера: http://localhost:6080
FROM base AS mac

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        tigervnc-standalone-server tigervnc-common novnc websockify \
        openbox xterm dbus-x11 \
    && rm -rf /var/lib/apt/lists/*
COPY start-desktop.sh /usr/local/bin/start-desktop.sh
RUN chmod +x /usr/local/bin/start-desktop.sh
USER ${USER_NAME}

ENV DISPLAY=:1 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1
EXPOSE 6080
CMD ["/usr/local/bin/start-desktop.sh"]
