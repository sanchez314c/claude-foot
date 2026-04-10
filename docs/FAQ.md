# Frequently Asked Questions

## Where does ClawdFoot install?

The installer copies files to `~/.claude/clawdfoot/` and creates a symlink at `~/.claude/statusline.sh`. Claude Code reads that symlink path from its `settings.json` to load the status bar.

## Does it use API tokens or cost anything?

No. ClawdFoot runs entirely on your local machine. It reads system state from `/proc`, `pgrep`, `git`, and similar local sources. It makes zero network calls and consumes zero API tokens.

## Why is the status bar not showing?

Check these three things in order:

1. **settings.json** - Open `~/.claude/settings.json` and confirm it has a `statusLine` configuration pointing to `~/.claude/statusline.sh`
2. **Symlink** - Run `ls -la ~/.claude/statusline.sh` and verify it points to `~/.claude/clawdfoot/clawdfoot.sh`
3. **jq** - Run `jq --version`. If jq isn't installed, the script can't parse Claude Code's JSON input and will silently fail

If all three check out, restart Claude Code.

## Can I use it on macOS?

Yes. CPU metrics fall back from `/proc/loadavg` to `sysctl`. RAM metrics from `free` are not available on macOS, so that field shows N/A. Everything else works the same.

## How do I change themes?

Set the `CLAWDFOOT_THEME` environment variable before launching Claude Code:

```bash
export CLAWDFOOT_THEME=neon
```

Available built-in themes: `default`, `monochrome`, `neon`.

You can also set this in your shell profile (`~/.bashrc`, `~/.zshrc`) so it persists across sessions.

## Can I make my own theme?

Yes. Create a `.sh` file that defines 8 color variables used by the status bar. Look at the files in the `themes/` directory for the expected variable names and format. Set `CLAWDFOOT_THEME` to your theme file's name (without the `.sh` extension) and place it in the themes directory.

## Does it slow down Claude Code?

No noticeable impact. The script reads `/proc` files and runs a handful of lightweight commands (`pgrep`, `git status`, `ss`). There are no network calls, no disk-heavy operations, no background processes. Execution completes in milliseconds.

## What's the mood indicator?

The mood indicator is a context usage label that tells you how much of Claude Code's context window has been consumed:

| Context Used | Label |
|---|---|
| < 25% | FRESH |
| < 50% | WARMED UP |
| < 70% | DEEP IN IT |
| < 90% | RUNNING HOT |
| >= 90% | CRITICAL |

This helps you know when you're approaching the context limit and might want to start a new session.

## What does the agent count show?

It counts running Claude Code agent processes by searching for processes matching the `claude.*-p` pattern via `pgrep`. This tells you how many parallel Claude Code sessions or sub-agents are active on your machine.

## Does it work in WSL?

Yes. WSL provides `/proc` and standard Linux tooling, so ClawdFoot runs the same as on native Linux. Make sure `jq` and `bc` are installed in your WSL environment.
