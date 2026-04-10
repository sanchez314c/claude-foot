# ClawdFoot Development Learnings

Things we figured out the hard way, or things that aren't obvious from reading the code.

## Output Contract

The output must be exactly 2 lines. Not 1, not 3. Claude Code reads the statusline script output and expects a two-line format. Line 1 is session metrics (model, context, tokens, cost, time). Line 2 is system metrics (project, git, CPU, RAM, ports, agents). Break this contract and Claude Code ignores the output entirely.

## stdin Reading

The script uses `cat` to read all stdin at once into a variable, not line-by-line with `read`. This matters because the JSON payload from Claude Code comes as a single blob. Line-by-line reading would require reassembly and add latency.

## jq Fallback Values

jq's `// "default"` syntax provides fallback values when a JSON field is missing or null. This is used throughout the script because Claude Code's JSON payload doesn't always include every field. Older versions of Claude Code send fewer fields, and the script needs to handle that gracefully without crashing.

## CPU Readings

Using `/proc/loadavg` gives an instant CPU load reading without the multi-second delay that `top` or `mpstat` require. Those tools need to sample over time to produce meaningful numbers. `/proc/loadavg` is a single file read, which keeps the script under its 100ms budget.

## Agent Counting

`pgrep -fc 'claude.*-p'` counts running Claude sub-agents, but it can match false positives. Any process with "claude" and "-p" in its command line will count. This is a known tradeoff: accuracy vs. not adding a heavier detection mechanism.

## Theme Security

Theme files are `source`d into the running shell, meaning they execute in the same context as the main script. A malicious theme file could run arbitrary commands. This is acceptable for locally-installed themes but worth knowing if you're ever tempted to download themes from the internet.

## Installer Backup Behavior

The installer backs up any existing `statusline.sh` before overwriting it. If a user has a custom statusline setup, they can restore it after uninstalling ClawdFoot. The backup goes to `statusline.sh.bak` in the same directory.

## macOS Bash Version

macOS ships bash 3.x by default. ClawdFoot requires bash 4+ because of `pipefail` behavior differences between versions. The script doesn't currently use associative arrays (which also need 4+), but the pipefail difference alone can cause silent failures on bash 3. macOS users need to install bash via Homebrew.

## Floating Point Math

Bash can't do floating point arithmetic natively. Token counts like "142.5K" and cost values like "$0.42" require `bc` for the math. This is why `bc` is a hard dependency, not optional.

## Context Bar Width

The context progress bar is hardcoded to 20 characters wide. Changing this number affects the alignment of everything to the right of it on line 1. If you modify bar width, test with context values at 0%, 50%, and 100% to make sure the mood indicator and surrounding text still line up.
