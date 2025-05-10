#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Sync Notes
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Run git-auto-sync on notes directory
# @raycast.author pdxmph
# @raycast.authorURL https://raycast.com/pdxmph

set -euo pipefail
IFS=$'\n\t'

# ——— set up a user‐level log directory ———
LOGDIR="$HOME/Library/Logs/git-auto-sync"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/sync.log"

on_error() {
    local exit_code=$?
    local lineno=$1
    local msg="ERROR on line $lineno (exit $exit_code)"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ▶ $msg" >>"$LOGFILE"
    logger -t git-auto-sync "$msg"
    terminal-notifier \
        -title "🔥🤖🔥 git-auto-sync FAILED" \
        -message "See Console.app or $LOGFILE" \
        -sound default
    exit $exit_code
}
trap 'on_error $LINENO' ERR

{
    echo "=== Sync started at $(date '+%Y-%m-%d %H:%M:%S') ==="
    logger -t git-auto-sync "Sync started"
    cd "$HOME/notes"
    /opt/homebrew/bin/git-auto-sync s
    echo "=== Sync succeeded at $(date '+%Y-%m-%d %H:%M:%S') ==="
    logger -t git-auto-sync "Sync succeeded"
} >>"$LOGFILE" 2>&1

terminal-notifier \
    -title "🤖 git-auto-sync" \
    -message "Sync complete" \
    -sound default
