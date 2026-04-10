# ClawdFoot Development Guide

## Project Structure

```
clawdfoot.sh              # The entire status bar (185 lines)
install.sh                # Automated installer
uninstall.sh              # Clean uninstaller
themes/
  default.sh              # ANSI 16-color cyberpunk palette
  neon.sh                 # 256-color bright neon
  monochrome.sh           # Grayscale, works on any terminal
docs/                     # Documentation
```

There's no build system, no package manager, no compiled output, no node_modules, no virtual environment. You edit `clawdfoot.sh` and run it.

## Dev Workflow

1. Edit `clawdfoot.sh` in your editor
2. Pipe mock JSON to test:

```bash
echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":42,"total_input_tokens":84000,"total_output_tokens":12500},"cost":{"total_cost_usd":0.1337,"total_duration_ms":185000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ./clawdfoot.sh
```

3. Check edge cases (0% context, 100% context, missing fields, huge token counts)
4. Test with each theme:

```bash
CLAWDFOOT_THEME=neon ./clawdfoot.sh <<< '{"model":{"display_name":"Test"},"context_window":{"used_percentage":95,"total_input_tokens":900000,"total_output_tokens":300000},"cost":{"total_cost_usd":1.2345,"total_duration_ms":7200000},"workspace":{"current_dir":"'"$(pwd)"'"}}'
```

## Code Style

- Start with `set -euo pipefail`
- Stick to POSIX-compatible constructs where possible. Bash 4+ features (arrays, `[[ ]]`) are fine but nothing that requires bash 5+
- Use `//` defaults in every `jq` call so missing fields don't break the script
- All system commands that might not exist must be wrapped in `command -v` checks or `2>/dev/null` with fallbacks
- No external formatting dependencies. Colors are raw ANSI escape sequences only

## Adding a Theme

Create a new file in `themes/`, for example `themes/solarized.sh`:

```bash
# ClawdFoot Theme: Solarized
# Warm color palette based on Solarized Dark

RED='\033[38;5;160m'
YELLOW='\033[38;5;136m'
GREEN='\033[38;5;64m'
CYAN='\033[38;5;37m'
MAGENTA='\033[38;5;125m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
```

You must define all 8 variables. The script sources this file at runtime and uses these variables directly in `echo -e` statements. If any variable is missing, the output will have broken formatting.

Test it:

```bash
CLAWDFOOT_THEME=solarized ./clawdfoot.sh <<< '{"model":{"display_name":"Test"},"context_window":{"used_percentage":50,"total_input_tokens":50000,"total_output_tokens":10000},"cost":{"total_cost_usd":0.05,"total_duration_ms":60000},"workspace":{"current_dir":"'"$(pwd)"'"}}'
```

The `CLAWDFOOT_THEME` value must match the filename without `.sh`. So `themes/solarized.sh` is activated by `CLAWDFOOT_THEME=solarized`.

To use themes from a directory outside the project, set `CLAWDFOOT_THEME_DIR`:

```bash
CLAWDFOOT_THEME_DIR=/home/you/my-themes CLAWDFOOT_THEME=custom ./clawdfoot.sh <<< '...'
```

## Performance Rules

ClawdFoot runs on every single Claude Code interaction. If it takes 500ms, the user feels it. Keep it fast.

- No `sleep`, `wait`, or polling of any kind
- No network calls (no curl, no wget, no DNS lookups)
- No writing to disk (no temp files, no logs)
- Read `/proc` directly instead of spawning heavier utilities like `top`
- Minimize subshell spawns. Each `$(...)` forks a process
- `jq` and `bc` are the two heaviest dependencies and both are called multiple times. Don't add more

## Keeping Installer and Uninstaller in Sync

If you add a new file to the project (like a new default theme), you need to update both `install.sh` and `uninstall.sh`:

- `install.sh` copies files from the source directory to `~/.claude/clawdfoot/`. The theme copy uses a glob (`themes/*.sh`), so new theme files are picked up automatically. But if you add a non-theme file, you'll need to add a `cp` line.
- `uninstall.sh` removes `~/.claude/clawdfoot/` recursively, so new files inside that directory are handled. But if you install files elsewhere, add cleanup logic.

## Testing Edge Cases

These are the cases that tend to break things:

```bash
# Zero everything
echo '{"model":{"display_name":"Unknown"},"context_window":{"used_percentage":0,"total_input_tokens":0,"total_output_tokens":0},"cost":{"total_cost_usd":0,"total_duration_ms":0},"workspace":{"current_dir":"/tmp"}}' | ./clawdfoot.sh

# Maximum context
echo '{"model":{"display_name":"Opus 4.6 (1M context)"},"context_window":{"used_percentage":100,"total_input_tokens":999999999,"total_output_tokens":999999999},"cost":{"total_cost_usd":99.9999,"total_duration_ms":86400000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ./clawdfoot.sh

# Missing fields (jq defaults should handle this)
echo '{"model":{}}' | ./clawdfoot.sh

# Non-git directory
echo '{"model":{"display_name":"Test"},"context_window":{"used_percentage":50,"total_input_tokens":1000,"total_output_tokens":500},"cost":{"total_cost_usd":0.01,"total_duration_ms":30000},"workspace":{"current_dir":"/tmp"}}' | ./clawdfoot.sh
```

## Contributing Workflow

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-change`
3. Make your changes
4. Test with mock JSON (all themes, edge cases)
5. Update `CHANGELOG.md` with your change
6. Submit a PR with a clear description of what changed and why
