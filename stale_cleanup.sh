#!/bin/bash

# -----------------------------
# stale_cleanup (Terminal Output Only)
# -----------------------------
# Usage:
#   ./stale_cleanup.sh <days> <size_mb> <dir1> [dir2 ...]
# -----------------------------

set -e

DAYS="$1"
SIZE_MB="$2"
shift 2
DIRS="$@"

# Check if arguments are missing
if [[ -z "$DAYS" || -z "$SIZE_MB" || -z "$DIRS" ]]; then
  echo "Usage: stale_cleanup <days> <size_mb> <dir1> [dir2 ...]"
  exit 1
fi

echo "--------------------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting stale cleanup"
echo "Criteria: older than ${DAYS} days AND larger than ${SIZE_MB} MB"
echo "Directories: $DIRS"
echo "--------------------------------------------------"

for DIR in $DIRS; do
  if [[ ! -d "$DIR" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Skipping non-existent directory: $DIR"
    continue
  fi

  echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing directory: $DIR"

  # -ls: Prints file details to console
  # -delete: Removes the file
  # Note: -delete must come AFTER the criteria (-mtime and -size)
  find "$DIR" -type f \
    -mtime +"$DAYS" \
    -size +"${SIZE_MB}M" \
    -ls \
    -delete
done

echo "--------------------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleanup finished"