#!/usr/bin/env bash
# restore_popup.sh — centralized popup launcher for restore/archive/delete
# Usage: restore_popup.sh <restore|archive|unarchive|delete>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

ACTION="${1:-restore}"

# Border style — must match a valid popup-border-lines value.
# 'rounded' is the tmux global option name; -b accepts the same tokens.
# Fall back to the server default if our preferred style is rejected.
BORDER="rounded"

# Popup dimensions (must match session_manager.tmux defaults)
_POPUP_WIDTH="42%"
_POPUP_HEIGHT="35%"

# Colors per action
case "$ACTION" in
    restore)
        TITLE="#[bg=#242a30,fg=#7797b7,bold] || 󰗆 RESTORE SESSIONS || "
        SCRIPT="$SCRIPT_DIR/restore_session.sh"
        ;;
    archive)
        TITLE="#[bg=#242a30,fg=#7797b7,bold] || 󰗆 ARCHIVE SESSION || "
        SCRIPT="$SCRIPT_DIR/archive_session.sh"
        ;;
    unarchive)
        TITLE="#[bg=#242a30,fg=#7797b7,bold] || 󰗆 RESTORE ARCHIVED || "
        SCRIPT="$SCRIPT_DIR/restore_session.sh --archived"
        ;;
    delete)
        TITLE="#[bg=#242a30,fg=#e89199,bold] || 󰗆 DELETE SESSION || "
        SCRIPT="$SCRIPT_DIR/delete_session.sh"
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        exit 1
        ;;
esac

# Launch the popup.  -E auto-closes when the script exits.
# -b round uses the round border style (compatible with tmux 3.2+).
# -T accepts tmux style directives via #[...] for the popup title.
tmux display-popup \
    -E \
    -w "$_POPUP_WIDTH" \
    -h "$_POPUP_HEIGHT" \
    -b "$BORDER" \
    -T "$TITLE" \
    "$SCRIPT"
