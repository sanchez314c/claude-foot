# CLAUDE.md - ClawdFoot

## Project Overview

ClawdFoot is a dual-line status bar for Claude Code CLI. It receives JSON session data via stdin, combines it with live system metrics, and outputs two formatted lines that render at the bottom of the terminal.

## Architecture

Single bash script (`clawdfoot.sh`) with a theme system. No build step, no dependencies beyond `jq` and `bc`.

- **Entry point**: `clawdfoot.sh` -- reads JSON from stdin, outputs ANSI-formatted text to stdout
- **Themes**: `themes/*.sh` -- shell scripts that define color variables, sourced at runtime
- **Installer**: `install.sh` -- copies files to `~/.claude/clawdfoot/`, symlinks `~/.claude/statusline.sh`, configures `settings.json`
- **Uninstaller**: `uninstall.sh` -- removes installed files, restores previous statusline from backup

## Key Design Constraints

- Must run on every Claude Code interaction, so speed is critical (no network calls, no subprocesses beyond jq/bc/git)
- Zero API token consumption -- runs entirely locally
- Graceful degradation when optional tools (git, ss, netstat) are missing
- Linux primary, macOS via fallbacks, WSL supported

## File Layout

```
clawdfoot.sh          # Main statusline script
install.sh            # Automated installer
uninstall.sh          # Clean uninstaller
themes/default.sh     # Standard ANSI 16-color theme
themes/neon.sh        # 256-color neon theme
themes/monochrome.sh  # Grayscale theme
```

## Environment Variables

- `CLAWDFOOT_THEME` -- theme name (default|neon|monochrome or custom)
- `CLAWDFOOT_THEME_DIR` -- path to custom theme directory

## Testing

Pipe mock JSON to the script:

```bash
echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":42,"total_input_tokens":84000,"total_output_tokens":12500},"cost":{"total_cost_usd":0.1337,"total_duration_ms":185000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ./clawdfoot.sh
```

## Dependencies

- `jq` (required) -- JSON parsing
- `bc` (required) -- arithmetic for token formatting
- `git` (optional) -- branch/status display
- `ss` or `netstat` (optional) -- port counting
- `bash` 4+
