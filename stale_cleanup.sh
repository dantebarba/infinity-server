#!/bin/bash

# -----------------------------
# stale_cleanup
# -----------------------------
# Usage:
#   stale_cleanup <days> <size_mb> <dir1> [dir2 ...]
#
# Example:
#   stale_cleanup 30 100 /var/log /tmp /data/backups
# -----------------------------

set -e

LOG_FILE="/var/log/stale-cleanup.log"

DAYS="$1"
SIZE_MB="$2"
shift 2
DIRS="$@"

if [[ -z "$DAYS" || -z "$SIZE_MB" || -z "$DIRS" ]]; then
  echo "Usage: stale_cleanup <days> <size_mb> <dir1> [dir2 ...]" | tee -a "$LOG_FILE"
  exit 1
fi

echo "--------------------------------------------------" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting stale cleanup" >> "$LOG_FILE"
echo "Criteria: older than ${DAYS} days AND larger than ${SIZE_MB} MB" >> "$LOG_FILE"
echo "Directories: $DIRS" >> "$LOG_FILE"

for DIR in $DIRS; do
  if [[ ! -d "$DIR" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipping non-existent directory: $DIR" >> "$LOG_FILE"
    continue
  fi

  echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing directory: $DIR" >> "$LOG_FILE"

  find "$DIR" -type f \
    -mtime +"$DAYS" \
    -size +"${SIZE_MB}M" \
    -print -delete >> "$LOG_FILE" 2>&1
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleanup finished" >> "$LOG_FILE"
