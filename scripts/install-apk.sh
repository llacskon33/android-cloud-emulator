#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Uso: $0 /ruta/a/app.apk"
  exit 1
fi

APK_PATH="$1"
if [ ! -f "$APK_PATH" ]; then
  echo "No existe el archivo: $APK_PATH"
  exit 1
fi

adb wait-for-device
adb install -r "$APK_PATH"
