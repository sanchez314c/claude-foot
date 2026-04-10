# Troubleshooting

## "jq: command not found"

`jq` is required. ClawdFoot receives JSON from Claude Code via stdin and uses jq to parse it.

```bash
# Debian/Ubuntu
sudo apt install jq

# macOS
brew install jq

# Fedora
sudo dnf install jq
```

## "bc: command not found"

`bc` is required for arithmetic operations like calculating CPU and memory percentages.

```bash
# Debian/Ubuntu
sudo apt install bc

# macOS (usually pre-installed)
brew install bc

# Fedora
sudo dnf install bc
```

## Status bar not appearing

Work through these checks:

1. **Verify settings.json** - Open `~/.claude/settings.json` and look for the `statusLine` key. It should reference `~/.claude/statusline.sh`.

2. **Verify the symlink** - Run:
   ```bash
   ls -la ~/.claude/statusline.sh
   ```
   It should point to `~/.claude/clawdfoot/clawdfoot.sh`. If the symlink is broken or missing, re-run `install.sh`.

3. **Verify jq is installed** - Run `jq --version`. Without jq, the script exits silently.

4. **Restart Claude Code** - Settings changes only take effect after a restart.

## Garbled output or no colors

Your terminal doesn't support ANSI escape sequences, or its color support is limited. Switch to the monochrome theme:

```bash
export CLAWDFOOT_THEME=monochrome
```

If output is still garbled, check that your terminal emulator supports at least 16 colors. The neon theme uses 256-color sequences and won't render correctly in basic terminals.

## Git info shows "no git"

This means either:
- The current working directory isn't inside a git repository
- `git` isn't installed

This is normal behavior. The git section only populates when Claude Code is working inside a git repo.

## Port count shows "?"

Neither `ss` nor `netstat` is installed. These are optional dependencies used to count listening ports.

```bash
# Debian/Ubuntu
sudo apt install iproute2    # provides ss
# or
sudo apt install net-tools   # provides netstat
```

## macOS CPU shows 0%

The macOS fallback uses `sysctl -n vm.loadavg` to read CPU load. On some macOS versions, this returns unexpected formats. This is a known limitation. Linux systems read `/proc/loadavg` directly and don't have this issue.

## Permission denied on install.sh

The script needs execute permission:

```bash
chmod +x install.sh
```

Same applies if you get permission denied on `clawdfoot.sh` or `uninstall.sh`.

## Agent count seems wrong

The agent counter uses `pgrep` to match processes against the pattern `claude.*-p`. It counts any running process whose command line matches that pattern. If you have other processes with similar names, they may be included in the count. If `pgrep` isn't available, the count shows 0.

## Theme not loading

Check that:
- The theme name matches a file in the `themes/` directory (without the `.sh` extension)
- The environment variable is set before Claude Code starts: `export CLAWDFOOT_THEME=neon`
- The theme file defines all 8 required color variables (compare against `themes/default.sh`)

## Still stuck?

Run the script manually to see raw output:

```bash
echo '{"context_window_percent": 42}' | bash ~/.claude/clawdfoot/clawdfoot.sh
```

If this produces two lines of formatted output, the script works. The problem is in the Claude Code integration (settings.json or symlink).
