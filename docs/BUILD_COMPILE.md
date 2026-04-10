# Build & Compile

ClawdFoot has no build step. It's a pure Bash script, interpreted directly at runtime by your shell.

## There Is Nothing to Build

- No compilation
- No bundling or minification
- No transpilation
- No dependencies to install via a package manager

The closest thing to a "build" is making the script executable:

```bash
chmod +x clawdfoot.sh
chmod +x install.sh
chmod +x uninstall.sh
```

## Distribution

Copy the `.sh` files and `themes/` directory to the target machine. That's it.

The recommended method is cloning the repo and running the installer:

```bash
git clone https://github.com/sanchez314c/claude-foot.git
cd claude-foot
./install.sh
```

## What the Installer Does

`install.sh` handles everything that would normally be a "build" step in other projects:

1. Copies `clawdfoot.sh` and theme files to `~/.claude/clawdfoot/`
2. Creates a symlink at `~/.claude/statusline.sh` pointing to the installed script
3. Configures Claude Code's `settings.json` with the statusLine entry
4. Verifies that required dependencies (`jq`, `bc`) are present

No compilation artifacts are produced. No build cache exists. Nothing to clean.

## Platform Notes

ClawdFoot runs on Linux, macOS, and WSL. The script handles platform differences internally at runtime:

- **CPU metrics**: Reads `/proc/loadavg` on Linux. Falls back to `sysctl -n vm.loadavg` on macOS.
- **RAM metrics**: Uses `free` on Linux. RAM display is unavailable on macOS (shows N/A).
- **Process counting**: Uses `pgrep` on all platforms.
- **Network ports**: Uses `ss` or falls back to `netstat`.

No platform-specific build configuration is needed. The same script runs everywhere.

## Runtime Requirements

- Bash 4.0 or later
- `jq` 1.5+ (parses JSON input from Claude Code)
- `bc` (arithmetic for percentage calculations)
- `git` (optional, for branch/status display)
- `ss` or `netstat` (optional, for port counting)
