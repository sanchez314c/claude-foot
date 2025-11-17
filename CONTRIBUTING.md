# Contributing to ClawdFoot

Thanks for your interest in contributing to ClawdFoot!

## How to Contribute

### Reporting Bugs

Open an issue with:
- Your OS and terminal emulator
- Claude Code version (`claude --version`)
- The output of running the script manually:
  ```bash
  echo '{"model":{"display_name":"Test"},"context_window":{"used_percentage":50,"total_input_tokens":1000,"total_output_tokens":500},"cost":{"total_cost_usd":0.01,"total_duration_ms":30000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ~/.claude/clawdfoot/clawdfoot.sh
  ```
- What you expected vs what happened

### Adding Themes

1. Create a new file in `themes/` (e.g., `themes/mytheme.sh`)
2. Define the required color variables: `RED`, `YELLOW`, `GREEN`, `CYAN`, `MAGENTA`, `DIM`, `BOLD`, `RESET`
3. Test with `CLAWDFOOT_THEME=mytheme` and the mock input above
4. Submit a PR

### Code Changes

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-change`
3. Test your changes with mock JSON input
4. Keep the script POSIX-compatible where possible (bash 4+ is fine)
5. Submit a PR with a clear description

## Guidelines

- Keep it fast — the script runs on every Claude Code interaction
- No network calls — everything should be local
- Graceful degradation — missing tools should produce fallback output, not errors
- ANSI colors only — no external formatting dependencies
