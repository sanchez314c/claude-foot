## Summary

What does this PR do? Keep it brief.

## Changes

- ...
- ...

## Type

- [ ] Bug fix
- [ ] New feature
- [ ] New theme
- [ ] Documentation
- [ ] Refactor

## Testing

Describe how you tested this. At minimum, run the mock JSON test:

```bash
echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":42,"total_input_tokens":84000,"total_output_tokens":12500},"cost":{"total_cost_usd":0.1337,"total_duration_ms":185000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ./clawdfoot.sh
```

- [ ] Tested on Linux
- [ ] Tested on macOS (if applicable)
- [ ] Tested with all three built-in themes
- [ ] No new dependencies added

## Checklist

- [ ] Script still runs in under 100ms
- [ ] Output is still exactly two lines
- [ ] No network calls introduced
- [ ] Graceful fallback when optional tools are missing
- [ ] CHANGELOG.md updated
