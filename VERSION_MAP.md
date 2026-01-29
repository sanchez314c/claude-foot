# VERSION_MAP.md - ClawdFoot

## Version History

| Version | Date       | Description                                    |
|---------|------------|------------------------------------------------|
| 1.0.0   | 2026-02-09 | Initial release. Dual-line status bar with themes, installer, uninstaller |

## Compatibility Matrix

| ClawdFoot Version | Claude Code Version | Bash Version | jq Version |
|-------------------|---------------------|--------------|------------|
| 1.0.x             | Any with statusLine support | 4.0+   | 1.5+       |

## Platform Support

| Platform       | Version | Status         |
|----------------|---------|----------------|
| Linux (Ubuntu) | 20.04+  | Full support   |
| Linux (Other)  | Any     | Full support   |
| macOS          | 12+     | Supported with fallbacks |
| Windows (WSL)  | WSL 2   | Supported      |
| Windows        | Native  | Not supported  |

## Theme Compatibility

All themes work on all supported platforms. The `neon` theme requires a terminal with 256-color support. The `monochrome` theme works on any terminal.
