#!/usr/bin/env bash
set -euo pipefail

LOG=/tmp/switch_timing.log
echo "START $(date +%s%N)" >> "$LOG"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"
echo "AFTER_SOURCE $(date +%s%N)" >> "$LOG"

# get_active_sessions
current="$(tmux display-message -p "#{session_name}")"
echo "AFTER_CURRENT_DISPLAY $(date +%s%N)" >> "$LOG"

tmux list-sessions -F "#{session_name}" 2>/dev/null > /tmp/sessions_raw.txt
echo "AFTER_LIST_SESSIONS $(date +%s%N)" >> "$LOG"

echo "END $(date +%s%N)" >> "$LOG"
cat /tmp/sessions_raw.txt
