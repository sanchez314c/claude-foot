# ClawdFoot API Reference

ClawdFoot has no CLI flags, no arguments, and no interactive mode. It reads JSON from stdin and writes two lines to stdout. That's the full interface.

## Input: JSON via stdin

Claude Code pipes a JSON object to the script on every assistant response. ClawdFoot reads it with `cat` and parses individual fields with `jq`.

### Input JSON Schema

```json
{
  "model": {
    "display_name": "string"
  },
  "context_window": {
    "used_percentage": "number (0-100)",
    "total_input_tokens": "number",
    "total_output_tokens": "number"
  },
  "cost": {
    "total_cost_usd": "number",
    "total_duration_ms": "number"
  },
  "workspace": {
    "current_dir": "string (absolute path)"
  }
}
```

### Field Details

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `model.display_name` | string | `"Unknown"` | Name of the active Claude model, shown on Line 1 |
| `context_window.used_percentage` | number | `0` | Context window fill level (0-100), drives the progress bar and mood indicator |
| `context_window.total_input_tokens` | number | `0` | Cumulative input tokens for the session, shown with K/M suffix |
| `context_window.total_output_tokens` | number | `0` | Cumulative output tokens for the session, shown with K/M suffix |
| `cost.total_cost_usd` | number | `0` | Session cost in USD, shown as `$X.XXXX` |
| `cost.total_duration_ms` | number | `0` | Wall-clock session time in milliseconds, converted to `Xh Xm` or `Xm Xs` or `Xs` |
| `workspace.current_dir` | string | `""` | Absolute path to the current project. Used for the project name (basename) and git detection |

Every field has a `jq` default via `//`, so missing or null fields produce sensible output instead of errors.

## Output: Two ANSI Lines to stdout

The script writes exactly two lines to stdout using `echo -e`. Both contain ANSI escape sequences for color and formatting. Claude Code renders these at the bottom of the terminal.

### Line 1 -- Session Metrics

```
{MODEL} | {BAR}{PCT}% {MOOD} | ↑{IN} ↓{OUT} | {COST} | {DURATION}
```

| Segment | Example | Color Logic |
|---------|---------|-------------|
| Model | `Opus 4.6` | Bold cyan, always |
| Context bar | `##########----------` | Green < 50%, yellow < 70%, red >= 70% |
| Percentage | `50%` | Same color as bar |
| Mood | `DEEP IN IT` | Same color as bar |
| Input tokens | `↑84.0K` | Green, always |
| Output tokens | `↓12.5K` | Yellow, always |
| Cost | `$0.1337` | Cyan, always |
| Duration | `3m 5s` | Dim, always |

**Mood thresholds:**

| Context % | Mood Label |
|-----------|------------|
| 0-24 | FRESH |
| 25-49 | WARMED UP |
| 50-69 | DEEP IN IT |
| 70-89 | RUNNING HOT |
| 90-100 | CRITICAL |

### Line 2 -- System Metrics

```
{PROJECT} | {GIT} | cpu:{PCT}% | ram:{USED}/{TOTAL}G | ports:{COUNT} | agents:{COUNT}
```

| Segment | Example | Color Logic |
|---------|---------|-------------|
| Project | `my-project` | Magenta, always |
| Git branch | `main ~3` or `main clean` | Cyan branch, yellow dirty count or green "clean" |
| Git (no repo) | `no git` | Dim |
| CPU | `cpu:18%` | Green < 50%, yellow < 80%, red >= 80% |
| RAM | `ram:69/125G` | Green < 50%, yellow < 80%, red >= 80% |
| Ports | `ports:33` | Dim, always |
| Agents | `agents:2` | Dim, always |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAWDFOOT_THEME` | `default` | Theme name. Must match a filename in the themes directory (without `.sh`). Ships with `default`, `neon`, `monochrome`. |
| `CLAWDFOOT_THEME_DIR` | `<script_dir>/themes` | Absolute path to a directory containing theme `.sh` files. Defaults to the `themes/` directory next to `clawdfoot.sh` (resolved via `readlink -f`). |

If `CLAWDFOOT_THEME_DIR` is set, ClawdFoot looks for `${CLAWDFOOT_THEME_DIR}/${CLAWDFOOT_THEME}.sh`. If that file doesn't exist, it falls back to hardcoded default colors.

## Theme API

A theme is a shell script that defines 8 variables. ClawdFoot sources it with `source "${THEME_DIR}/${THEME}.sh"`.

### Required Variables

```bash
RED='\033[31m'       # High alerts: critical context, CPU >= 80%, RAM >= 80%
YELLOW='\033[33m'    # Moderate alerts: mid-range context, CPU >= 50%, RAM >= 50%
GREEN='\033[32m'     # Normal state: low context, healthy CPU/RAM, clean git
CYAN='\033[36m'      # Accents: model name, cost display
MAGENTA='\033[35m'   # Project name
DIM='\033[2m'        # Secondary info: separators, ports, agents, duration
BOLD='\033[1m'       # Emphasis: model name
RESET='\033[0m'      # Clear all formatting
```

All 8 must be defined. The values can be any valid ANSI escape sequence. The `neon` theme uses 256-color codes (`\033[38;5;XXXm`). The `monochrome` theme maps all color variables to white/gray.

### Theme File Naming

The filename (without `.sh`) is the theme name. `themes/neon.sh` is activated by `CLAWDFOOT_THEME=neon`.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success. Two lines written to stdout. |
| Non-zero | A command in the pipeline failed. Typically `jq` failing to parse malformed JSON, or `bc` failing on bad arithmetic input. Due to `set -euo pipefail`, any failed command exits the script immediately. |

There are no custom exit codes. The script relies on bash's `set -e` to propagate failures from `jq`, `bc`, and other commands.

## Invocation

ClawdFoot takes no flags and no arguments. The only valid way to call it:

```bash
echo '{"model":...}' | clawdfoot.sh
```

Or as configured in Claude Code's `settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Claude Code handles the piping automatically. The script never needs to be called with arguments.

## Token Formatting

Input and output token counts are formatted with K/M suffixes by the `fmt_tok` function:

| Range | Format | Example |
|-------|--------|---------|
| 0-999 | Raw number | `500` |
| 1,000-999,999 | X.XK | `84.0K` |
| 1,000,000+ | X.XM | `1.2M` |

Division is handled by `bc` with `scale=1` for one decimal place.
