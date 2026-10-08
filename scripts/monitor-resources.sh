#!/bin/bash
# Prints CPU, memory, disk and emulator status every INTERVAL seconds.
# Usage: monitor-resources.sh [interval_seconds] [count (0 = forever)]
INTERVAL="${1:-5}"
COUNT="${2:-0}"
i=0
while true; do
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    cpu="$(top -bn1 | awk '/Cpu\(s\)/ {printf "%.1f", 100-$8}')"
    mem="$(free -m | awk '/Mem:/ {printf "%d/%dMB (%.0f%%)", $3,$2,$3*100/$2}')"
    disk="$(df -h /data 2>/dev/null | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
    if pgrep -f 'qemu-system' >/dev/null; then emu=running; else emu=stopped; fi
    boot="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    echo "$ts cpu=${cpu}% mem=$mem disk=$disk emulator=$emu boot_completed=${boot:-n/a}"
    i=$((i+1))
    if [ "$COUNT" -gt 0 ] && [ "$i" -ge "$COUNT" ]; then break; fi
    sleep "$INTERVAL"
done
