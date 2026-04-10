# Technology Stack

## Language

**Bash 4.0+** - The entire project is a single shell script (clawdfoot.sh, ~185 lines). No other programming language is used. Bash 4+ is required for associative arrays and certain string operations.

## Required Dependencies

**jq 1.5+** - JSON parser. Claude Code pipes JSON data to the status bar script via stdin. jq extracts fields like context window percentage, model name, and session info. Without jq, the script cannot function.

**bc (GNU bc)** - Arbitrary precision calculator. Used for arithmetic operations that Bash can't handle natively, like dividing load averages by core counts to get CPU percentage, and calculating memory usage percentages.

## Optional Dependencies

**git** - Used to display the current branch name and repository status (clean/dirty). If git isn't installed or the working directory isn't a repo, the git section shows "no git."

**ss** (from iproute2) or **netstat** (from net-tools) - Used to count listening network ports. The script tries `ss` first, falls back to `netstat`. If neither is available, the port count shows "?".

## System Tools Used

**pgrep** - Counts running Claude Code agent processes by matching the `claude.*-p` pattern. Shows how many parallel sessions are active.

**nproc** - Returns the number of CPU cores. Used to normalize the load average into a percentage.

**free** - Reports memory usage on Linux. Not available on macOS, where RAM display shows N/A.

## System Interfaces

**/proc/loadavg** - Read directly for CPU load on Linux. Faster than running a command. On macOS, the script falls back to `sysctl -n vm.loadavg`.

## Output Format

**ANSI escape sequences** - The script outputs two formatted lines using ANSI color codes. The default and monochrome themes use standard 16-color codes. The neon theme uses 256-color extended sequences.

## What's Not in the Stack

- No package manager (npm, pip, cargo, etc.)
- No build tools (make, webpack, etc.)
- No runtime (Node, Python, etc.)
- No framework
- No database
- No network calls
- No configuration language (YAML, TOML, etc.) - settings are shell variables and Claude Code's settings.json
