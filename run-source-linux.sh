#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== ClawdFoot — Test Run (Linux) ==="

# Check dependencies
for dep in jq bc; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "ERROR: $dep is required. Install with: sudo apt install $dep"
    exit 1
  fi
done

echo "Dependencies OK (jq, bc)"
echo ""

# Run with mock JSON input
echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"used_percentage":42,"total_input_tokens":84000,"total_output_tokens":12500},"cost":{"total_cost_usd":0.1337,"total_duration_ms":185000},"workspace":{"current_dir":"'"$(pwd)"'"}}' | ./clawdfoot.sh

echo ""
echo "=== Test complete. To install, run: ./install.sh ==="
