# Deployment

ClawdFoot is a local tool. It runs on your machine, inside your terminal, attached to your Claude Code session. There is no server, no remote deployment, no infrastructure.

## How Users Get It

Distribution is through GitHub. Users clone the repo and run the installer:

```bash
git clone https://github.com/sanchez314c/claude-foot.git
cd claude-foot
./install.sh
```

The installer copies files to `~/.claude/clawdfoot/`, sets up the symlink, and configures `settings.json`. After that, restarting Claude Code activates the status bar.

## Uninstalling

```bash
./uninstall.sh
```

This removes the installed files, the symlink, and the settings.json configuration entry.

## Release Process

ClawdFoot uses manual releases. When pushing a new version:

1. Update the version comment in the `clawdfoot.sh` script header
2. Update `CHANGELOG.md` with what changed
3. Commit the changes
4. Tag the release:
   ```bash
   git tag -a v1.x.x -m "Description of release"
   ```
5. Push the tag:
   ```bash
   git push origin main --tags
   ```

## What's Not Here

- **No CI/CD pipeline.** The project is a single Bash script. Automated builds don't apply.
- **No package registry publishing.** Not on npm, Homebrew, apt, or any other package manager.
- **No Docker image.** ClawdFoot reads local system state (/proc, process lists, git repos). Containerizing it would defeat the purpose.
- **No CDN or artifact hosting.** The GitHub repo is the single source of truth.

## Updating an Existing Install

Pull the latest changes and re-run the installer:

```bash
cd claude-foot
git pull
./install.sh
```

The installer overwrites the previously installed files in `~/.claude/clawdfoot/`. Settings are preserved.
