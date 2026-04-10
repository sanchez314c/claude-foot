# ClawdFoot Development Workflow

## Branching

Fork the repo, then create a feature branch off `main`:

```bash
git checkout -b feature/my-change
```

Bug fixes use `fix/description`, docs use `docs/description`.

## Code

Edit the bash scripts directly. There's no build step, no transpilation, no bundling. `clawdfoot.sh` is the entire application at 185 lines. Themes live as separate source files.

Keep changes minimal. Every line in a status bar script runs on every single Claude Code interaction, so bloat matters.

## Test

Pipe mock JSON into the script and verify output:

```bash
echo '{"model":"opus","session":{"id":"abc","costUSD":0.42},"context":{"contextWindow":200000,"used":85000},"tokenUsage":{"input":12000,"output":3500,"cacheRead":8000,"cacheWrite":1200}}' | bash clawdfoot.sh
```

Check that:
- Output is exactly 2 lines (Claude Code expects this contract)
- ANSI colors render correctly in your terminal
- No errors appear on stderr

Test all 3 themes:

```bash
export CLAWDFOOT_THEME=default   # then pipe JSON
export CLAWDFOOT_THEME=neon      # then pipe JSON
export CLAWDFOOT_THEME=monochrome # then pipe JSON
```

## Performance Check

The script must complete in under 100ms. Measure it:

```bash
time echo '{"model":"opus"}' | bash clawdfoot.sh
```

Rules for keeping it fast:
- No network calls, ever
- No new external dependencies beyond jq and bc
- No loops over large datasets
- Read /proc files instead of spawning tools like `top`

## Pull Requests

Submit PRs against `main` with a clear description of what changed and why. Reference the issue number if one exists. Include before/after terminal screenshots if the change affects visual output.

## Release Process

1. Update the version string in the `clawdfoot.sh` script header
2. Update CHANGELOG.md with what changed
3. Commit: `git commit -m "release: vX.Y.Z"`
4. Tag: `git tag vX.Y.Z`
5. Push: `git push origin main --tags`

There's no CI/CD pipeline. Testing is manual. The project is a single bash script, so automated pipelines would be overkill.
