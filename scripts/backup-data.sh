#!/bin/bash
# Backs up /data (AVD + userdata) into /backups as timestamped tar.gz.
# Usage: backup-data.sh [backup|restore <file>]  ; RETENTION env = backups to keep (default 5)
set -euo pipefail
SRC="${DATA_DIR:-/data}"
DEST="${BACKUP_DIR:-/backups}"
RETENTION="${RETENTION:-5}"
mkdir -p "$DEST"
case "${1:-backup}" in
    backup)
        file="$DEST/android-data-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar -czf "$file" -C "$SRC" .
        echo "Backup created: $file"
        ls -1t "$DEST"/android-data-*.tar.gz | tail -n +$((RETENTION+1)) | xargs -r rm -f
        ;;
    restore)
        file="${2:?usage: backup-data.sh restore <file>}"
        tar -xzf "$file" -C "$SRC"
        echo "Restored from $file"
        ;;
    *) echo "usage: $0 [backup|restore <file>]"; exit 1 ;;
esac
