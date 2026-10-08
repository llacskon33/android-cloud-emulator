#!/bin/bash
set -euo pipefail
mkdir -p ~/.vnc
x11vnc -storepasswd "$VNC_PASSWORD" ~/.vnc/passwd >/dev/null
exec x11vnc -display :0 -rfbauth ~/.vnc/passwd -forever -shared -rfbport 5900 -noxdamage
