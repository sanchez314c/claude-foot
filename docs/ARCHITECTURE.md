# ClawdFoot Architecture

## Single Script Design

ClawdFoot is one bash script: `clawdfoot.sh` at 185 lines. There's no build step, no transpilation, no package manager. The script runs directly as a shell command invoked by Claude Code on every assistant response.

Supporting files are the installer (`install.sh`), uninstaller (`uninstall.sh`), and three theme files in `themes/`. That's the entire project.

## Data Flow

```
Claude Code                    clawdfoot.sh                     Terminal
    |                              |                                |
    |--- JSON via stdin --->       |                                |
    |                         cat (read stdin)                      |
    |                         jq (parse JSON fields)                |
    |                         /proc/loadavg (CPU)                   |
    |                         free (RAM)                            |
    |                         git (branch + dirty count)            |
    |                         ss/netstat (listening ports)           |
    |                         pgrep (sub-agent count)               |
    |                              |                                |
    |<--- 2 lines ANSI text ---    |                                |
    |                                                               |
    |--- renders at bottom ---------------------------------------->|
```

Claude Code pipes a JSON blob containing session data (model name, context usage, token counts, cost, duration, working directory) to `clawdfoot.sh` via stdin. The script reads it with `cat`, parses fields with `jq`, collects live system metrics from the OS, formats everything with ANSI escape codes, and writes exactly two lines to stdout. Claude Code renders those two lines at the bottom of the terminal.

## Entry Point

`clawdfoot.sh` starts with `set -euo pipefail` and immediately reads all of stdin into a variable:

```bash
input=$(cat)
```

It then runs `jq` against that variable seven times to extract each field: model name, context percentage, input tokens, output tokens, cost, duration, and working directory. Each `jq` call uses `// "fallback"` to handle missing fields gracefully.

## Theme System

Themes are plain shell scripts in the `themes/` directory. Each one defines exactly 8 color variables:

| Variable | Purpose |
|----------|---------|
| `RED` | High alerts, critical context, high CPU/RAM |
| `YELLOW` | Moderate alerts, mid-range metrics |
| `GREEN` | Normal/healthy state |
| `CYAN` | Model name, cost display |
| `MAGENTA` | Project name |
| `DIM` | Separators, secondary info (ports, agents, time) |
| `BOLD` | Model name emphasis |
| `RESET` | Clear all formatting |

Theme selection happens at the top of the script:

```bash
THEME_DIR="${CLAWDFOOT_THEME_DIR:-$(dirname "$(readlink -f "$0")")/themes}"
THEME="${CLAWDFOOT_THEME:-default}"
```

If a matching theme file exists at `${THEME_DIR}/${THEME}.sh`, it gets sourced. Otherwise the script falls back to hardcoded default colors (standard ANSI 16-color). This means ClawdFoot always works even if theme files are missing.

### Shipped Themes

- `default.sh` -- Standard ANSI 16-color, the cyberpunk grid palette
- `neon.sh` -- 256-color bright neon (needs a 256-color terminal)
- `monochrome.sh` -- All variables mapped to white/gray, works on any terminal

## Output Format

The script produces exactly two lines, separated by a newline. Both lines use ANSI escape sequences for color. Fields within each line are separated by a dimmed `|` character.

**Line 1 -- Session metrics:**

```
{MODEL} | {CONTEXT_BAR} {PCT}% {MOOD} | ↑{IN_TOKENS} ↓{OUT_TOKENS} | {COST} | {DURATION}
```

- Context bar: 20-character wide, `#` for filled, `-` for empty
- Mood labels: FRESH (< 25%), WARMED UP (< 50%), DEEP IN IT (< 70%), RUNNING HOT (< 90%), CRITICAL (>= 90%)

**Line 2 -- System metrics:**

```
{PROJECT} | {GIT_BRANCH} {DIRTY_COUNT|clean} | cpu:{PCT}% | ram:{USED}/{TOTAL}G | ports:{COUNT} | agents:{COUNT}
```

## Install Location

The installer copies files to `~/.claude/clawdfoot/` and creates a symlink:

```
~/.claude/
  clawdfoot/
    clawdfoot.sh          # The main script
    themes/
      default.sh
      neon.sh
      monochrome.sh
  statusline.sh           # Symlink -> clawdfoot/clawdfoot.sh
  settings.json           # Contains statusLine config
```

Claude Code reads `settings.json` to find the statusline command:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

## System Metric Collection

All metrics are collected without network calls or sleeps. The script reads directly from the OS:

| Metric | Source | Fallback |
|--------|--------|----------|
| CPU % | `/proc/loadavg` divided by `nproc` | macOS: `sysctl -n vm.loadavg` |
| RAM | `free -m` | macOS: reports "N/A" |
| Git branch | `git -C $WORK_DIR branch --show-current` | Shows "no git" |
| Git dirty count | `git -C $WORK_DIR status --porcelain \| wc -l` | Skipped |
| Listening ports | `ss -tlnp \| wc -l` | `netstat -tln \| wc -l`, then "?" |
| Sub-agents | `pgrep -fc 'claude.*-p'` | "0" |
| Project name | `basename` of `workspace.current_dir` | `basename $(pwd)` |

## Performance Considerations

This script executes on every Claude Code interaction. It needs to finish fast. Key decisions:

- Read `/proc/loadavg` directly instead of running `top` or `mpstat`
- Use `free` once instead of parsing `/proc/meminfo`
- No `sleep`, no polling, no retry loops
- Git commands use `-C` to avoid `cd` subshells
- Token formatting uses `bc` for division (lighter than awk for single calculations)
- Separate `jq` calls per field instead of one giant jq filter, to keep error handling simple and each extraction independent
