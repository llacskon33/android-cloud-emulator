#!/bin/bash
# Container entrypoint: validates environment and launches all services.
set -euo pipefail

export SCREEN_RESOLUTION="${SCREEN_RESOLUTION:-1080x1920x24}"
export EMULATOR_RAM="${EMULATOR_RAM:-4096}"
export EMULATOR_CORES="${EMULATOR_CORES:-4}"
export VNC_PASSWORD="${VNC_PASSWORD:-}"

if [ -z "$VNC_PASSWORD" ]; then
    VNC_PASSWORD="$(head -c 12 /dev/urandom | base64 | tr -d '/+=')"
    export VNC_PASSWORD
    echo "[start] VNC_PASSWORD not set; generated random password: $VNC_PASSWORD"
fi

if [ -e /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "[start] KVM acceleration available"
else
    echo "[start] WARNING: /dev/kvm not accessible; emulator will be very slow. Run with --device /dev/kvm"
fi

mkdir -p "$ANDROID_AVD_HOME"
if ! avdmanager list avd 2>/dev/null | grep -q "cloud_android"; then
    echo "[start] Creating AVD cloud_android"
    echo no | avdmanager create avd -n cloud_android \
        -k "system-images;android-${ANDROID_API};${SYSTEM_IMAGE_TAG};${ANDROID_ABI}" \
        -d pixel_6 --force
fi

if [ "$#" -gt 0 ]; then exec "$@"; fi
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
