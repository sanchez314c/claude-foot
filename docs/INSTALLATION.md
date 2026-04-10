# ClawdFoot Installation Guide

## Prerequisites

**Required:**
- Claude Code CLI -- installed and configured (the `~/.claude/` directory must exist)
- `jq` -- JSON parser. Install: `sudo apt install jq` (Ubuntu/Debian) or `brew install jq` (macOS)
- `bc` -- math utility. Usually pre-installed on Linux. Install: `sudo apt install bc` or `brew install bc`
- `bash` 4.0 or later. Check with `bash --version`

**Optional (for full metrics):**
- `git` -- enables branch name and dirty file count on Line 2
- `ss` or `netstat` -- enables listening port count on Line 2

Without the optional tools, those fields show fallback values ("no git", "?" for ports) instead of real data.

## Automated Installation

```bash
git clone https://github.com/sanchez314c/ClawdFoot.git
cd ClawdFoot
chmod +x install.sh
./install.sh
```

The installer does the following:

1. Checks that `jq` is installed (exits with an error if missing, warns for other missing deps)
2. Confirms `~/.claude/` exists (exits if Claude Code isn't installed)
3. Backs up any existing `~/.claude/statusline.sh` to `~/.claude/statusline.sh.backup.YYYYMMDD_HHMMSS`
4. Creates `~/.claude/clawdfoot/themes/`
5. Copies `clawdfoot.sh` and all theme files into `~/.claude/clawdfoot/`
6. Makes `clawdfoot.sh` executable
7. Creates a symlink: `~/.claude/statusline.sh -> ~/.claude/clawdfoot/clawdfoot.sh`
8. Updates `~/.claude/settings.json` to add the `statusLine` config (creates the file if it doesn't exist)
9. Runs a verification test with mock JSON and shows the output

After install, send any message in Claude Code and the status bar will appear at the bottom of the terminal.

## Manual Installation

If you'd rather not run the installer:

```bash
# Create the directory structure
mkdir -p ~/.claude/clawdfoot/themes

# Copy files
cp clawdfoot.sh ~/.claude/clawdfoot/
cp themes/*.sh ~/.claude/clawdfoot/themes/

# Make executable
chmod +x ~/.claude/clawdfoot/clawdfoot.sh

# Create the symlink Claude Code will call
ln -sf ~/.claude/clawdfoot/clawdfoot.sh ~/.claude/statusline.sh
```

Then edit `~/.claude/settings.json` (create it if it doesn't exist) and add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

If `settings.json` already has other keys, just add the `statusLine` block to the existing object. Don't overwrite the whole file.

## Verification

Test the installation by piping mock JSON directly:

```bash
echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":42,"total_input_tokens":84000,"total_output_tokens":12500},"cost":{"total_cost_usd":0.1337,"total_duration_ms":185000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ~/.claude/clawdfoot/clawdfoot.sh
```

You should see two colorized lines. If you get errors about `jq` or `bc`, install the missing dependency and try again.

## Theme Selection

Set your preferred theme with an environment variable:

```bash
export CLAWDFOOT_THEME=neon
```

Available themes: `default`, `neon`, `monochrome`. To persist the choice, add that export to your `~/.bashrc` or `~/.zshrc`.

For custom themes from a different directory:

```bash
export CLAWDFOOT_THEME_DIR=/path/to/my/themes
export CLAWDFOOT_THEME=mytheme
```

## Uninstallation

```bash
cd ClawdFoot
./uninstall.sh
```

The uninstaller will:

1. Remove the `~/.claude/statusline.sh` symlink
2. Restore your previous statusline from the most recent backup file, if one exists
3. Delete `~/.claude/clawdfoot/` and everything in it
4. Remove the `statusLine` key from `~/.claude/settings.json` (if it points to ClawdFoot)
5. Re-add the `statusLine` config pointing to the restored backup, if applicable

Restart Claude Code or send a message to see the change take effect.

## Troubleshooting

**No status bar appears after install:**
- Check that `~/.claude/settings.json` has the `statusLine` block
- Check that `~/.claude/statusline.sh` exists and is executable
- Run the verification command above to see if the script produces output

**"jq: command not found":**
- Install jq: `sudo apt install jq` or `brew install jq`

**"bc: command not found":**
- Install bc: `sudo apt install bc` or `brew install bc`

**Git info shows "no git":**
- This is normal for non-git directories. If you're in a git repo and it still shows "no git", check that `git` is installed and the `.git` directory is accessible from the workspace path.

**Status bar looks garbled:**
- Your terminal might not support ANSI colors. Try `CLAWDFOOT_THEME=monochrome` for the simplest output.
- If using the neon theme, your terminal needs 256-color support.
