# ClawdFoot Quick Start

Get a dual-line status bar in Claude Code CLI in under 2 minutes.

## Steps

1. Install the two required dependencies:

```bash
sudo apt install jq bc
```

2. Clone the repo:

```bash
git clone https://github.com/sanchez314c/ClawdFoot.git
```

3. Move into the directory:

```bash
cd ClawdFoot
```

4. Run the installer:

```bash
./install.sh
```

5. Start using Claude Code normally. The status bar appears after your next interaction.

6. Want a different look? Set a theme:

```bash
export CLAWDFOOT_THEME=neon
```

Available themes: `default`, `neon`, `monochrome`.

That's it. No config files to edit, no daemons to start, no API keys needed.

## Uninstall

If you want to remove it:

```bash
./uninstall.sh
```

The uninstaller restores your original statusline configuration if one existed.
