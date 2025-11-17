# Changelog

All notable changes to ClawdFoot will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-03-13

### Performance
- Consolidated 7 separate `jq` subprocess calls into a single invocation (H1) -- ~85% reduction in process spawning per invocation
- Replaced `bc` dependency in token formatter with pure bash arithmetic (L1) -- `bc` no longer required at runtime

### Fixed
- Replaced `readlink -f` (GNU-only) with portable symlink resolution for macOS compatibility (M1)
- Fixed shell variable injection in awk CPU calculation -- now uses `-v` flag (M4)
- Tightened `pgrep` pattern for agent counting to reduce false positives (M3)
- Fixed `pgrep -c` double-output issue when no agents are running

## [1.0.2] - 2026-03-13

### Repository Compliance
- Created `.editorconfig` for consistent formatting
- Created `run-source-linux.sh` (mock JSON test runner)
- Created `run-source-mac.sh` (mock JSON test runner)
- Created `run-source-windows.bat` (WSL redirect)
- Created `resources/icons/` directory with `.gitkeep`
- Created `tests/` directory with `.gitkeep`
- Added `.gitkeep` to `archive/`
- Synced `AGENTS.md` with `CLAUDE.md`
- Updated `.gitignore` with missing patterns: `archive/`, `legacy/`, `._*`, `Desktop.ini`, `.cache/`, `coverage/`
- Created timestamped archive backup `20260313_180013.tar.gz`

## [1.0.1] - 2026-03-13

### Documentation
- Added 15 standard documentation files in `docs/`
- Created docs/README.md (documentation index)
- Created docs/ARCHITECTURE.md (system design, data flow, component relationships)
- Created docs/INSTALLATION.md (prerequisites, automated and manual setup)
- Created docs/DEVELOPMENT.md (dev environment, testing, code style)
- Created docs/API.md (JSON input schema, output format, env vars, theme API)
- Created docs/BUILD_COMPILE.md (no-build architecture, installer operations)
- Created docs/DEPLOYMENT.md (local deployment, GitHub distribution, release process)
- Created docs/FAQ.md (10 real questions with code-derived answers)
- Created docs/TROUBLESHOOTING.md (common errors, platform issues, debugging)
- Created docs/TECHSTACK.md (full dependency inventory with versions)
- Created docs/WORKFLOW.md (branching, testing, PR, release cycle)
- Created docs/QUICK_START.md (6-step clone-to-running guide)
- Created docs/LEARNINGS.md (development gotchas and insights)
- Created docs/PRD.md (product requirements, goals, non-goals)
- Created docs/TODO.md (known issues, planned features, tech debt)

## [1.0.0] - 2026-02-09

### Added
- Dual-line status bar for Claude Code CLI
- **Line 1**: Model name, 20-char context progress bar with mood indicator, input/output token counts, session cost, elapsed time
- **Line 2**: Project name, git branch + dirty file count, CPU load, RAM usage, active listening ports, sub-agent count
- Context mood system: FRESH / WARMED UP / DEEP IN IT / RUNNING HOT / CRITICAL
- Color-coded thresholds for CPU, RAM, and context usage (green/yellow/red)
- Token formatting with K/M suffixes
- Theme support via `CLAWDFOOT_THEME` environment variable
- Three built-in themes: `default`, `neon`, `monochrome`
- Custom theme support via `CLAWDFOOT_THEME_DIR`
- `install.sh` — automated installer with backup, dependency check, and verification
- `uninstall.sh` — clean removal with backup restoration
- macOS fallback for CPU/RAM metrics
- Fallback to `netstat` when `ss` is unavailable
