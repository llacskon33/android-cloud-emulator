#!/bin/bash
# Host setup: installs Docker + KVM prerequisites on Ubuntu/Debian and starts the emulator.
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run as root (sudo)"; exit 1; fi
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl cpu-checker qemu-kvm
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
if kvm-ok; then echo "KVM OK"; else echo "WARNING: KVM unavailable (enable nested virtualization on cloud VMs)"; fi
cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.example .env
docker compose up -d --build
echo "Open http://<host>:6080 (password in .env or container logs)"
