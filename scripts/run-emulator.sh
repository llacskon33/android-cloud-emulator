#!/bin/bash
set -euo pipefail
ACCEL=()
if [ -w /dev/kvm ]; then
    ACCEL=(-accel on -gpu swiftshader_indirect)
else
    ACCEL=(-accel off -gpu swiftshader_indirect)
fi
emulator -avd cloud_android -no-audio -no-boot-anim -no-snapshot-save \
    -memory "$EMULATOR_RAM" -cores "$EMULATOR_CORES" \
    "${ACCEL[@]}" -port 5554 \
    2>&1
