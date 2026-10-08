# syntax=docker/dockerfile:1

# ---------- Stage 1: Android SDK builder ----------
FROM ubuntu:22.04 AS sdk-builder
ARG DEBIAN_FRONTEND=noninteractive
ARG CMDLINE_TOOLS_VERSION=11076708
ARG ANDROID_API=34
ARG SYSTEM_IMAGE_TAG=google_apis
ARG ANDROID_ABI=x86_64
ENV ANDROID_SDK_ROOT=/opt/android-sdk

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless wget unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip -O /tmp/tools.zip \
    && unzip -q /tmp/tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm /tmp/tools.zip

ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin
RUN yes | sdkmanager --licenses >/dev/null \
    && sdkmanager --install \
        "platform-tools" "emulator" \
        "platforms;android-${ANDROID_API}" \
        "system-images;android-${ANDROID_API};${SYSTEM_IMAGE_TAG};${ANDROID_ABI}"

# ---------- Stage 2: Runtime ----------
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG ANDROID_API=34
ARG SYSTEM_IMAGE_TAG=google_apis
ARG ANDROID_ABI=x86_64

LABEL org.opencontainers.image.title="android-cloud-emulator" \
      org.opencontainers.image.description="Android emulator (QEMU/KVM) with VNC and noVNC" \
      org.opencontainers.image.licenses="MIT"

ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_AVD_HOME=/data/avd \
    ANDROID_API=${ANDROID_API} \
    SYSTEM_IMAGE_TAG=${SYSTEM_IMAGE_TAG} \
    ANDROID_ABI=${ANDROID_ABI} \
    DISPLAY=:0 \
    PATH=/opt/android-sdk/emulator:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:/opt/scripts:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless xvfb x11vnc novnc websockify supervisor \
        fluxbox qemu-kvm libpulse0 libnss3 libgl1 libx11-6 libxcomposite1 \
        libxcursor1 libxdamage1 libxi6 libxtst6 libxrandr2 libasound2 \
        libxkbfile1 procps tar curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

COPY --from=sdk-builder ${ANDROID_SDK_ROOT} ${ANDROID_SDK_ROOT}
COPY scripts/ /opt/scripts/
COPY config/supervisord.conf /etc/supervisord.conf
RUN chmod +x /opt/scripts/*.sh

# Run as unprivileged user (needs access to /dev/kvm via --device)
RUN useradd -m -u 1000 -s /bin/bash android \
    && mkdir -p /data /backups \
    && chown -R android:android /data /backups /opt/android-sdk
USER android
WORKDIR /home/android

VOLUME ["/data", "/backups"]
# 6080: noVNC (web), 5900: VNC, 5554/5555: emulator console / adb
EXPOSE 6080 5900 5554 5555

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
    CMD curl -fsS http://localhost:6080/ >/dev/null || exit 1

ENTRYPOINT ["/opt/scripts/start-emulator.sh"]
