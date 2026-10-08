FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    PATH=${PATH}:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator

WORKDIR /opt

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    wget \
    ca-certificates \
    default-jdk-headless \
    xvfb \
    qemu-system-x86 \
    qemu-utils \
    net-tools \
    iproute2 \
    python3 \
    python3-pip \
    git \
    supervisor \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    cd /tmp && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip -q cmdline-tools.zip && \
    mv cmdline-tools /opt/android-sdk/cmdline-tools/latest && \
    rm -f /tmp/cmdline-tools.zip && \
    yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk "platform-tools" "platforms;android-34" "build-tools;34.0.0" "system-images;android-34;google_apis;x86_64" "emulator" \
    && /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk --licenses

COPY scripts/start-emulator.sh /opt/start-emulator.sh
COPY scripts/install-apk.sh /opt/install-apk.sh
RUN chmod +x /opt/start-emulator.sh /opt/install-apk.sh

EXPOSE 5554 5555 6080 5900

CMD ["/bin/bash", "/opt/start-emulator.sh"]
