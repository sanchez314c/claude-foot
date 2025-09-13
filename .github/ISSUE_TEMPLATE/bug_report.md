---
name: Bug Report
about: Report a problem with ClawdFoot status bar
title: "[BUG] "
labels: bug
assignees: sanchez314c
---

## Description

A clear description of what went wrong.

## Environment

- **OS**: (e.g., Ubuntu 24.04, macOS 14.2, WSL2)
- **Terminal**: (e.g., Alacritty, iTerm2, GNOME Terminal)
- **Bash version**: (output of `bash --version`)
- **Claude Code version**: (output of `claude --version`)
- **ClawdFoot theme**: (default / neon / monochrome / custom)
- **jq version**: (output of `jq --version`)

## Steps to Reproduce

1. ...
2. ...
3. ...

## Expected Behavior

What you expected to see.

## Actual Behavior

What actually happened. Include terminal output if possible.

## Manual Test Output

Run this and paste the output:

```bash
echo '{"model":{"display_name":"Test"},"context_window":{"used_percentage":50,"total_input_tokens":1000,"total_output_tokens":500},"cost":{"total_cost_usd":0.01,"total_duration_ms":30000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ~/.claude/clawdfoot/clawdfoot.sh
```

## Additional Context

Any other details, screenshots, or logs.
