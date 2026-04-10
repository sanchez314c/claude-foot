# ClawdFoot TODO

## Known Issues

- **Agent count false positives.** `pgrep -fc 'claude.*-p'` can match processes that aren't actually Claude sub-agents. Any process with "claude" and "-p" in its command line gets counted. Needs a more precise detection pattern.

- **macOS RAM shows N/A.** The `free` command doesn't exist on macOS and no equivalent has been implemented yet. The RAM metric just displays N/A on Mac systems.

- **macOS CPU fallback reliability.** The macOS CPU reading falls back to a less reliable method than the Linux /proc/loadavg approach. Results can be inconsistent on Apple Silicon vs Intel Macs.

## Planned Features

- **More themes.** Solarized, Dracula, and Gruvbox themes to match popular terminal color schemes.

- **Configurable bar width.** Let users set CLAWDFOOT_BAR_WIDTH to control the context progress bar size. Currently hardcoded to 20 chars. Needs to dynamically adjust alignment of everything to the right of the bar.

- **Optional third line.** A user-configurable third line for custom info. Could pull from a user-defined script or environment variables. Requires updating the output contract with Claude Code.

- **Disk usage metric.** Show available disk space for the current partition. Useful for long sessions that generate lots of cached data.

- **Network activity indicator.** A simple up/down indicator showing whether there's active network traffic. Not a bandwidth meter, just a binary "traffic yes/no" signal.

## Tech Debt

- The macOS CPU fallback path should be tested more thoroughly across different macOS versions and hardware. Current implementation was written on Linux and adapted.

## Nice-to-Have

- **Man page.** A proper `man clawdfoot` page for users who prefer that over reading docs on GitHub.

- **Homebrew formula.** A `brew install clawdfoot` path for macOS users. Would handle the bash 4+ dependency automatically and make installation a single command.
