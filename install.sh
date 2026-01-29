#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║  ClawdFoot Installer                                 ║
# ║  Installs the dual-line statusline for Claude Code   ║
# ╚══════════════════════════════════════════════════════╝

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
error() { echo -e "${RED}[ClawdFoot]${RESET} $1" >&2; }

echo -e "${BOLD}${CYAN}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║       ClawdFoot Installer v1.0.0      ║"
echo "  ║   Dual-Line Statusline for Claude Code║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${RESET}"

# ── Check dependencies ──
info "Checking dependencies..."

MISSING_DEPS=()
for dep in jq bc git; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    MISSING_DEPS+=("$dep")
  fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  warn "Missing optional dependencies: ${MISSING_DEPS[*]}"
  echo "  Install with: sudo apt install ${MISSING_DEPS[*]}"
  echo ""

  # jq is required, others are optional
  if [[ " ${MISSING_DEPS[*]} " =~ " jq " ]]; then
    error "jq is REQUIRED. Install it first: sudo apt install jq"
    exit 1
  fi
fi

# ── Check Claude Code is installed ──
if [ ! -d "$CLAUDE_DIR" ]; then
  error "Claude Code config directory not found at ${CLAUDE_DIR}"
  error "Is Claude Code installed? Run: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

# ── Backup existing statusline if present ──
if [ -f "${CLAUDE_DIR}/statusline.sh" ]; then
  BACKUP="${CLAUDE_DIR}/statusline.sh.backup.$(date +%Y%m%d_%H%M%S)"
  warn "Existing statusline found. Backing up to: $(basename "$BACKUP")"
  cp "${CLAUDE_DIR}/statusline.sh" "$BACKUP"
fi

# ── Install ClawdFoot files ──
info "Installing ClawdFoot to ${INSTALL_DIR}..."

mkdir -p "${INSTALL_DIR}/themes"

cp "${SCRIPT_DIR}/clawdfoot.sh" "${INSTALL_DIR}/clawdfoot.sh"
cp "${SCRIPT_DIR}/themes/"*.sh "${INSTALL_DIR}/themes/" 2>/dev/null || true

chmod +x "${INSTALL_DIR}/clawdfoot.sh"

ok "Script installed to ${INSTALL_DIR}/clawdfoot.sh"

# ── Create symlink at standard location ──
ln -sf "${INSTALL_DIR}/clawdfoot.sh" "${CLAUDE_DIR}/statusline.sh"
chmod +x "${CLAUDE_DIR}/statusline.sh"
ok "Symlinked to ${CLAUDE_DIR}/statusline.sh"

# ── Update Claude Code settings.json ──
info "Configuring Claude Code settings..."

if [ ! -f "$SETTINGS_FILE" ]; then
  # Create minimal settings file
  echo '{}' > "$SETTINGS_FILE"
fi

# Check if statusLine is already configured
if jq -e '.statusLine' "$SETTINGS_FILE" >/dev/null 2>&1; then
  EXISTING_CMD=$(jq -r '.statusLine.command // .statusLine // ""' "$SETTINGS_FILE")
  if [[ "$EXISTING_CMD" == *"statusline.sh"* ]] || [[ "$EXISTING_CMD" == *"clawdfoot"* ]]; then
    ok "statusLine already configured correctly in settings.json"
  else
    warn "statusLine is configured with a different command: ${EXISTING_CMD}"
    warn "Updating to ClawdFoot..."
    TMPFILE=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' "$SETTINGS_FILE" > "$TMPFILE"
    mv "$TMPFILE" "$SETTINGS_FILE"
    ok "Settings updated"
  fi
else
  # Add statusLine configuration
  TMPFILE=$(mktemp)
  jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS_FILE" > "$TMPFILE"
  mv "$TMPFILE" "$SETTINGS_FILE"
  ok "statusLine added to settings.json"
fi

# ── Verify installation ──
info "Verifying installation..."

TEST_OUTPUT=$(echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":15,"total_input_tokens":5000,"total_output_tokens":1200},"cost":{"total_cost_usd":0.0234,"total_duration_ms":45000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | "${INSTALL_DIR}/clawdfoot.sh" 2>/dev/null)

if [ -n "$TEST_OUTPUT" ]; then
  ok "Verification passed! Output preview:"
  echo ""
  echo -e "  $TEST_OUTPUT" | head -2 | while IFS= read -r line; do echo -e "  $line"; done
  echo ""
else
  warn "Verification produced no output — check dependencies"
fi

# ── Done ──
echo -e "${BOLD}${GREEN}"
echo "  ════════════════════════════════════════"
echo "  Installation complete!"
echo "  ════════════════════════════════════════"
echo -e "${RESET}"
echo "  The status bar will appear at the bottom of Claude Code"
echo "  after your next interaction."
echo ""
echo "  Theme:     export CLAWDFOOT_THEME=neon   (default|neon|monochrome)"
echo "  Uninstall: ./uninstall.sh"
echo ""
