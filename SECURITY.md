# Security Policy

## About ClawdFoot Security

ClawdFoot is a bash script that reads JSON from stdin and outputs formatted text to stdout. It has a minimal attack surface:

- Reads only from stdin (piped by Claude Code)
- Writes only to stdout
- No network access
- No file writes
- Depends on standard Unix tools: `jq`, `bc`, `git`, `ss`, `nproc`, `free`
- Theme files are sourced bash scripts from a local directory

## Potential Concerns

- **Theme injection**: Custom theme files (`.sh`) are sourced via `source`. Only install themes from trusted sources. The default theme is embedded in the main script.
- **JSON parsing**: Input is processed through `jq`. Malformed JSON will cause jq to error, not execute arbitrary code.

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

If you find a security issue, please report it responsibly:

1. Open a GitHub Security Advisory at the project repository
2. Or contact [@sanchez314c](https://github.com/sanchez314c) directly

Do not open a public issue for security vulnerabilities. You should expect a response within 48 hours.
