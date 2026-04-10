# ClawdFoot Product Requirements

## Problem

Claude Code CLI shows minimal information about your active session. You don't know how much context you've burned, what model you're on, what the session is costing, or whether your system is under load. You end up guessing, or you run separate commands to check, which breaks your flow.

## Solution

A dual-line status bar that appears after every Claude Code interaction. Line 1 shows session info: model name, context usage with a visual progress bar, token counts (input/output/cache), cost in USD, and session duration. Line 2 shows system info: project name, git branch and status, CPU load, RAM usage, active ports, and running Claude sub-agent count.

It's a single bash script. It reads JSON from stdin, formats it, and writes 2 lines of ANSI-colored text to stdout. Nothing else.

## Target Users

Claude Code CLI power users who spend hours in sessions and want to know at a glance:
- How close they are to hitting the context window limit
- How much the session has cost so far
- What model is active
- Whether their system is straining under agent workloads

## Core Features

**Context progress bar with mood indicator.** A 20-char visual bar showing context window usage. Includes an emoji that shifts from happy to stressed as context fills up.

**Token counts with K/M formatting.** Input, output, cache read, and cache write tokens displayed in human-readable format (e.g., 12.5K, 1.2M) instead of raw numbers.

**Cost tracking.** Running cost in USD pulled directly from Claude Code's session data. No API calls, no external lookups.

**Git status.** Current branch name and dirty/clean state from the working directory.

**System resource monitoring.** CPU load from /proc/loadavg, RAM usage from /proc/meminfo (Linux) or vm_stat (macOS), active listening ports via ss or netstat.

**Theme support.** 3 built-in themes (default, neon, monochrome) selectable via the CLAWDFOOT_THEME environment variable. Themes control ANSI color codes only.

## Non-Goals

- Not a monitoring daemon. It runs once per invocation, not continuously.
- Not a log viewer. It doesn't read or display Claude Code logs.
- Not a notification system. No alerts, no sounds, no popups.
- Doesn't write files. Stateless, read-only operation.
- Doesn't make network calls. Zero external requests, zero API token cost.

## Success Criteria

- Installs in under 30 seconds on a fresh system with jq and bc available
- Runs in under 100ms per invocation
- Adds zero API token cost (reads only local data)
- Works on Linux, macOS, and WSL without modification (minus known macOS RAM limitation)
- Single script, no runtime dependencies beyond jq and bc
