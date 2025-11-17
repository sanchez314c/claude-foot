# ClawdFoot

A dual-line status bar for [Claude Code](https://claude.ai/code) CLI that displays real-time session metrics and system health at a glance.

```
Opus 4.6 | ##########---------- 50% DEEP IN IT | ↑12.3K ↓4.5K | $0.0234 | 2m 15s
my-project | main ~3 | cpu:18% | ram:69/125G | ports:33 | agents:2
```

## What It Shows

**Line 1 — Session Metrics**
| Field | Description |
|-------|-------------|
| Model | Active Claude model name |
| Context Bar | 20-char visual progress bar with fill percentage |
| Mood | Context state: `FRESH` < 25% / `WARMED UP` < 50% / `DEEP IN IT` < 70% / `RUNNING HOT` < 90% / `CRITICAL` >= 90% |
| Tokens | `↑` input / `↓` output with K/M suffixes |
| Cost | Session cost in USD |
| Duration | Elapsed wall-clock time |

**Line 2 — System Metrics**
| Field | Description |
|-------|-------------|
| Project | Current working directory name |
| Git | Branch name + dirty file count (or `no git`) |
| CPU | Load average as percentage (color-coded) |
| RAM | Used/total in GB (color-coded) |
| Ports | Count of active listening TCP ports |
| Agents | Count of running Claude sub-agent processes |

All metrics are color-coded: green (normal), yellow (moderate), red (high).

## Requirements

- **Claude Code** CLI installed and configured
- **jq** — JSON parser (required)
- **bc** — calculator for token formatting (required)
- **git** — for branch/status display (optional)
- **ss** or **netstat** — for port counting (optional)
- **bash** 4+

## Installation

```bash
git clone https://github.com/sanchez314c/ClawdFoot.git
cd ClawdFoot
chmod +x install.sh
./install.sh
```

The installer will:
1. Check for required dependencies (`jq`, `bc`)
2. Back up any existing statusline at `~/.claude/statusline.sh`
3. Copy ClawdFoot to `~/.claude/clawdfoot/`
4. Symlink to `~/.claude/statusline.sh`
5. Configure `~/.claude/settings.json` with the statusLine command
6. Verify the installation with a test run

## Uninstallation

```bash
cd ClawdFoot
./uninstall.sh
```

This removes ClawdFoot and restores your previous statusline from backup if one exists.

## Manual Installation

If you prefer to do it yourself:

```bash
# Copy the script
mkdir -p ~/.claude/clawdfoot/themes
cp clawdfoot.sh ~/.claude/clawdfoot/
cp themes/*.sh ~/.claude/clawdfoot/themes/
chmod +x ~/.claude/clawdfoot/clawdfoot.sh

# Symlink or copy
ln -sf ~/.claude/clawdfoot/clawdfoot.sh ~/.claude/statusline.sh
```

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

## Themes

ClawdFoot ships with three themes:

| Theme | Description |
|-------|-------------|
| `default` | Standard ANSI 16-color cyberpunk palette |
| `neon` | Bright 256-color neon aesthetic |
| `monochrome` | Clean grayscale for minimal terminals |

Set a theme via environment variable:

```bash
export CLAWDFOOT_THEME=neon
```

To persist, add it to your `~/.bashrc` or `~/.zshrc`.

### Custom Themes

Create a shell script in `themes/` that defines these variables:

```bash
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
CYAN='\033[36m'
MAGENTA='\033[35m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
```

Point to a custom theme directory:

```bash
export CLAWDFOOT_THEME_DIR=/path/to/my/themes
export CLAWDFOOT_THEME=mytheme
```

## Testing

Test with mock JSON input without running Claude Code:

```bash
echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":42,"total_input_tokens":84000,"total_output_tokens":12500},"cost":{"total_cost_usd":0.1337,"total_duration_ms":185000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ./clawdfoot.sh
```

## How It Works

Claude Code sends JSON session data to the statusline script via stdin on every assistant message. ClawdFoot parses this with `jq`, combines it with live system metrics (CPU, RAM, ports, git), and outputs two formatted lines that Claude Code renders at the bottom of the terminal.

The script runs locally and consumes zero API tokens.

### Available JSON Fields

ClawdFoot uses these fields from the Claude Code session data:

| Field | Used For |
|-------|----------|
| `model.display_name` | Model name display |
| `context_window.used_percentage` | Progress bar + mood |
| `context_window.total_input_tokens` | Input token count |
| `context_window.total_output_tokens` | Output token count |
| `cost.total_cost_usd` | Session cost |
| `cost.total_duration_ms` | Elapsed time |
| `workspace.current_dir` | Project name + git detection |

See the full schema in the [Claude Code statusline docs](https://code.claude.com/docs/en/statusline).

## Platform Support

| Platform | Status |
|----------|--------|
| Linux | Full support (primary target) |
| macOS | Supported with fallbacks for CPU/RAM |
| Windows (WSL) | Supported via WSL bash |
| Windows (native) | Not supported — use WSL |

## License

[MIT](LICENSE)
