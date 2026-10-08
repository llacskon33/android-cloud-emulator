#!/bin/bash
set -euo pipefail

export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator"

Xvfb :99 -screen 0 1280x720x24 >/tmp/xvfb.log 2>&1 &
export DISPLAY=:99

if [ ! -d "$ANDROID_HOME/avd/cloud_android.avd" ]; then
  echo "[INFO] Creating AVD..."
  echo "no" | avdmanager create avd -n cloud_android -k "system-images;android-34;google_apis;x86_64" -d pixel_6 --force
fi

rm -f /tmp/emulator.log

if ! pgrep -x "emulator" >/dev/null; then
  echo "[INFO] Starting Android emulator..."
  emulator @cloud_android \
    -no-window \
    -gpu swiftshader_indirect \
    -no-audio \
    -no-boot-anim \
    -memory 4096 \
    -cores 4 \
    -skin 1080x1920 \
    -verbose \
    -logcat '*:I' > /tmp/emulator.log 2>&1 &
fi

adb wait-for-device
adb devices

if [ -d /usr/share/novnc ]; then
  echo "[INFO] Starting noVNC on port 6080..."
  websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/tmp/novnc.log 2>&1 &
fi

echo "==========================================================="
echo "Android cloud emulator ready"
echo "- noVNC: http://localhost:6080/vnc.html"
echo "- ADB port: 5554/5555"
echo "- APK folder: /apks"
echo "==========================================================="

wait
