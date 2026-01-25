#!/bin/bash

# -----------------------------
# stale_cleanup
# -----------------------------
# Usage:
#   stale_cleanup <days> <size_mb> <dir1> [dir2 ...]
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

# Function to log to both console and file
log_msg() {
  echo "$1" | tee -a "$LOG_FILE"
}

log_msg "--------------------------------------------------"
log_msg "$(date '+%Y-%m-%d %H:%M:%S') - Starting stale cleanup"
log_msg "Criteria: older than ${DAYS} days AND larger than ${SIZE_MB} MB"
log_msg "Directories: $DIRS"

for DIR in $DIRS; do
  if [[ ! -d "$DIR" ]]; then
    log_msg "$(date '+%Y-%m-%d %H:%M:%S') - Skipping non-existent directory: $DIR"
    continue
  fi

  log_msg "$(date '+%Y-%m-%d %H:%M:%S') - Processing directory: $DIR"

  # -print shows the file, -delete removes it. 
  # Using 2>&1 and tee to catch everything.
  find "$DIR" -type f \
    -mtime +"$DAYS" \
    -size +"${SIZE_MB}M" \
    -print -delete 2>&1 | tee -a "$LOG_FILE"
done

log_msg "$(date '+%Y-%m-%d %H:%M:%S') - Cleanup finished"