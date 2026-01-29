#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║  ClawdFoot Uninstaller                               ║
# ║  Removes ClawdFoot and restores previous statusline  ║
# ╚══════════════════════════════════════════════════════╝

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
INSTALL_DIR="${CLAUDE_DIR}/clawdfoot"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

# ── Colors ──
RED='\033[31m'
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

info()  { echo -e "${CYAN}[ClawdFoot]${RESET} $1"; }
ok()    { echo -e "${GREEN}[ClawdFoot]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[ClawdFoot]${RESET} $1"; }

echo -e "${BOLD}${RED}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║      ClawdFoot Uninstaller v1.0.0     ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${RESET}"

# ── Remove symlink ──
if [ -L "${CLAUDE_DIR}/statusline.sh" ]; then
  rm "${CLAUDE_DIR}/statusline.sh"
  ok "Removed symlink: ${CLAUDE_DIR}/statusline.sh"
elif [ -f "${CLAUDE_DIR}/statusline.sh" ]; then
  warn "statusline.sh exists but is not a symlink — skipping (may be user-created)"
fi

# ── Restore backup if available ──
LATEST_BACKUP=$(ls -t "${CLAUDE_DIR}"/statusline.sh.backup.* 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ]; then
  cp "$LATEST_BACKUP" "${CLAUDE_DIR}/statusline.sh"
  chmod +x "${CLAUDE_DIR}/statusline.sh"
  ok "Restored previous statusline from: $(basename "$LATEST_BACKUP")"
fi

# ── Remove install directory ──
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  ok "Removed install directory: ${INSTALL_DIR}"
fi

# ── Remove statusLine from settings.json ──
if [ -f "$SETTINGS_FILE" ] && jq -e '.statusLine' "$SETTINGS_FILE" >/dev/null 2>&1; then
  EXISTING_CMD=$(jq -r '.statusLine.command // .statusLine // ""' "$SETTINGS_FILE")
  if [[ "$EXISTING_CMD" == *"statusline.sh"* ]] || [[ "$EXISTING_CMD" == *"clawdfoot"* ]]; then
    TMPFILE=$(mktemp)
    jq 'del(.statusLine)' "$SETTINGS_FILE" > "$TMPFILE"
    mv "$TMPFILE" "$SETTINGS_FILE"
    ok "Removed statusLine from settings.json"

    # If backup was restored, re-add statusLine pointing to it
    if [ -f "${CLAUDE_DIR}/statusline.sh" ]; then
      TMPFILE=$(mktemp)
      jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS_FILE" > "$TMPFILE"
      mv "$TMPFILE" "$SETTINGS_FILE"
      ok "Re-configured statusLine to use restored backup"
    fi
  else
    warn "statusLine points to a different script — leaving it unchanged"
  fi
fi

echo ""
echo -e "${BOLD}${GREEN}  Uninstall complete.${RESET}"
echo ""
echo "  ClawdFoot has been removed. Your previous statusline"
echo "  has been restored if a backup was found."
echo ""
echo "  Restart Claude Code or send a message to refresh the status bar."
echo ""
