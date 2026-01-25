#!/bin/bash

# -----------------------------
# stale_cleanup (Terminal Only)
# -----------------------------
# Usage:
#   ./stale_cleanup.sh <days> <size_mb> <dir1> [dir2 ...]
# -----------------------------

# Exit immediately if a command fails
set -e

# 1. Capture the first two arguments
DAYS="$1"
SIZE_MB="$2"

# 2. Check if arguments are missing BEFORE shifting
# We check for $3 because at least one directory is required
if [[ -z "$DAYS" || -z "$SIZE_MB" || -z "$3" ]]; then
  echo "Usage: stale_cleanup <days> <size_mb> <dir1> [dir2 ...]"
  echo "Example: ./stale_cleanup.sh 30 100 /var/log"
  exit 1
fi

# 3. Shift only after we know we have arguments to shift
shift 2
DIRS="$@"

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

  # -ls: Shows the file details (size, date)