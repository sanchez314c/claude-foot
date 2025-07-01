#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  ClawdFoot v1.0.0 — Claude Code Dual-Line Status Bar           ║
# ║  A cyberpunk-inspired statusline for Claude Code CLI            ║
# ║                                                                  ║
# ║  Line 1: Model | Context Bar + Mood | Tokens | Cost | Duration  ║
# ║  Line 2: Project | Git Branch | CPU | RAM | Ports | Agents      ║
# ╚══════════════════════════════════════════════════════════════════╝
#
# This script receives JSON session data from Claude Code via stdin
# and outputs a formatted dual-line status bar to stdout.
#
# Dependencies: jq, bc, git (optional), ss (optional)
# Platform: Linux (uses /proc/loadavg, free, ss, nproc)

set -euo pipefail

# ── Read JSON from Claude Code ──
input=$(cat)

# ── Extract session fields (single jq call for performance) ──
eval "$(echo "$input" | jq -r '
  "MODEL=" + (.model.display_name // "Unknown" | @sh) +
  " PCT=" + (.context_window.used_percentage // 0 | floor | tostring | @sh) +
  " INPUT_TOKENS=" + (.context_window.total_input_tokens // 0 | tostring | @sh) +
  " OUTPUT_TOKENS=" + (.context_window.total_output_tokens // 0 | tostring | @sh) +
  " COST=" + (.cost.total_cost_usd // 0 | tostring | @sh) +
  " DURATION_MS=" + (.cost.total_duration_ms // 0 | tostring | @sh) +
  " WORK_DIR=" + (.workspace.current_dir // "" | @sh)
')"

# ── Load theme (default inline, or source from themes/) ──
# Portable symlink resolution (works on macOS without GNU coreutils)
_resolve_script() {
  local path="$1"
  while [ -L "$path" ]; do
    local dir="$(cd "$(dirname "$path")" && pwd)"
    path="$(readlink "$path")"
    [[ "$path" != /* ]] && path="$dir/$path"
  done
  cd "$(dirname "$path")" && pwd
}
THEME_DIR="${CLAWDFOOT_THEME_DIR:-$(_resolve_script "$0")/themes}"
THEME="${CLAWDFOOT_THEME:-default}"

if [ -f "${THEME_DIR}/${THEME}.sh" ]; then
  # shellcheck source=/dev/null
  source "${THEME_DIR}/${THEME}.sh"
else
  # Default color scheme — cyberpunk grid aesthetic
  RED='\033[31m'
  YELLOW='\033[33m'
  GREEN='\033[32m'
  CYAN='\033[36m'
  MAGENTA='\033[35m'
  DIM='\033[2m'
  BOLD='\033[1m'
  RESET='\033[0m'
fi

SEP="${DIM}|${RESET}"

# ── Token formatter (K/M suffixes, pure bash — no bc dependency) ──
fmt_tok() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    local whole=$((n / 1000000))
    local frac=$(( (n % 1000000) / 100000 ))
    printf "%d.%dM" "$whole" "$frac"
  elif [ "$n" -ge 1000 ]; then
    local whole=$((n / 1000))
    local frac=$(( (n % 1000) / 100 ))
    printf "%d.%dK" "$whole" "$frac"
  else
    printf "%d" "$n"
  fi
}

IN_FMT=$(fmt_tok "$INPUT_TOKENS")
OUT_FMT=$(fmt_tok "$OUTPUT_TOKENS")

# ── Cost ──
COST_FMT=$(printf '$%.4f' "$COST")

# ── Duration ──
DURATION_SEC=$((DURATION_MS / 1000))
HOURS=$((DURATION_SEC / 3600))
MINS=$(( (DURATION_SEC % 3600) / 60 ))
SECS=$((DURATION_SEC % 60))
if [ "$HOURS" -gt 0 ]; then
  TIME_FMT="${HOURS}h ${MINS}m"
elif [ "$MINS" -gt 0 ]; then
  TIME_FMT="${MINS}m ${SECS}s"
else
  TIME_FMT="${SECS}s"
fi

# ── Context bar (20 wide) + mood indicator ──
BAR_WIDTH=20
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

if [ "$PCT" -ge 90 ]; then
  BAR_COLOR="$RED"; MOOD="CRITICAL"
elif [ "$PCT" -ge 70 ]; then
  BAR_COLOR="$RED"; MOOD="RUNNING HOT"
elif [ "$PCT" -ge 50 ]; then
  BAR_COLOR="$YELLOW"; MOOD="DEEP IN IT"
elif [ "$PCT" -ge 25 ]; then
  BAR_COLOR="$GREEN"; MOOD="WARMED UP"
else
  BAR_COLOR="$GREEN"; MOOD="FRESH"
fi

BAR_FILLED=$(printf "%${FILLED}s" | tr ' ' '#')
BAR_EMPTY=$(printf "%${EMPTY}s" | tr ' ' '-')

# ── Git info ──
GIT_INFO=""
if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR/.git" ]; then
  GIT_DIR="$WORK_DIR"
elif git -C "${WORK_DIR:-.}" rev-parse --git-dir >/dev/null 2>&1; then
  GIT_DIR="${WORK_DIR:-.}"
else
  GIT_DIR=""
fi

if [ -n "$GIT_DIR" ]; then
  BRANCH=$(git -C "$GIT_DIR" branch --show-current 2>/dev/null)
  DIRTY=$(git -C "$GIT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DIRTY" -gt 0 ]; then
    GIT_INFO="${CYAN}${BRANCH:-detached}${RESET} ${YELLOW}~${DIRTY}${RESET}"
  else
    GIT_INFO="${CYAN}${BRANCH:-detached}${RESET} ${GREEN}clean${RESET}"
  fi
else
  GIT_INFO="${DIM}no git${RESET}"
fi

# ── CPU usage (instant from /proc — no delay) ──
if [ -f /proc/loadavg ]; then
  LOAD=$(awk '{print $1}' /proc/loadavg 2>/dev/null)
  CORES=$(nproc 2>/dev/null || echo 1)
  CPU_PCT=$(awk -v lavg="$LOAD" -v ncpu="$CORES" 'BEGIN {v=(lavg/ncpu)*100; printf "%.0f", (v>100?100:v)}')
else
  # macOS fallback
  CPU_PCT=$(sysctl -n vm.loadavg 2>/dev/null | awk '{gsub(/[{}]/,""); print $1}' | awk -v c="$(sysctl -n hw.ncpu 2>/dev/null || echo 1)" 'BEGIN{}{printf "%.0f", ($1/c)*100}')
  CPU_PCT=${CPU_PCT:-0}
fi

if [ "$CPU_PCT" -ge 80 ]; then
  CPU_COLOR="$RED"
elif [ "$CPU_PCT" -ge 50 ]; then
  CPU_COLOR="$YELLOW"
else
  CPU_COLOR="$GREEN"
fi

# ── RAM usage ──
if command -v free >/dev/null 2>&1; then
  RAM_INFO=$(free -m 2>/dev/null | awk '/^Mem:/{printf "%.0f/%.0fG", $3/1024, $2/1024}')
  RAM_PCT=$(free 2>/dev/null | awk '/^Mem:/{printf "%.0f", $3/$2*100}')
else
  # macOS fallback
  RAM_INFO="N/A"
  RAM_PCT=0
fi

if [ -n "$RAM_PCT" ] && [ "$RAM_PCT" -ge 80 ]; then
  RAM_COLOR="$RED"
elif [ -n "$RAM_PCT" ] && [ "$RAM_PCT" -ge 50 ]; then
  RAM_COLOR="$YELLOW"
else
  RAM_COLOR="$GREEN"
fi

# ── Active listening ports (count) ──
if command -v ss >/dev/null 2>&1; then
  PORT_COUNT=$(ss -tlnp 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
elif command -v netstat >/dev/null 2>&1; then
  PORT_COUNT=$(netstat -tln 2>/dev/null | tail -n +3 | wc -l | tr -d ' ')
else
  PORT_COUNT="?"
fi

# ── Sub-agent count (matches 'claude -p' subagent pattern) ──
AGENT_COUNT=$(pgrep -fc 'claude .* -p ' 2>/dev/null) || AGENT_COUNT=0

# ── Project name from working dir ──
PROJECT=$(basename "${WORK_DIR:-$(pwd)}")

# ══════════════════════════════════════════
# LINE 1: Session metrics
# ══════════════════════════════════════════
echo -e "${BOLD}${CYAN}${MODEL}${RESET} ${SEP} ${BAR_COLOR}${BAR_FILLED}${DIM}${BAR_EMPTY}${RESET} ${BAR_COLOR}${PCT}%${RESET} ${BAR_COLOR}${MOOD}${RESET} ${SEP} ${GREEN}↑${IN_FMT}${RESET} ${YELLOW}↓${OUT_FMT}${RESET} ${SEP} ${CYAN}${COST_FMT}${RESET} ${SEP} ${DIM}${TIME_FMT}${RESET}"

# ══════════════════════════════════════════
# LINE 2: System metrics
# ══════════════════════════════════════════
echo -e "${MAGENTA}${PROJECT}${RESET} ${SEP} ${GIT_INFO} ${SEP} ${CPU_COLOR}cpu:${CPU_PCT}%${RESET} ${SEP} ${RAM_COLOR}ram:${RAM_INFO}${RESET} ${SEP} ${DIM}ports:${PORT_COUNT}${RESET} ${SEP} ${DIM}agents:${AGENT_COUNT}${RESET}"
