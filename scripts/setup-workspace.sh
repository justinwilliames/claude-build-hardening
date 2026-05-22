#!/usr/bin/env bash
# Set up the per-stage workspaces for a build-hardening run.
# Usage:
#   ./setup-workspace.sh <SPEC_PATH>

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <SPEC_PATH>" >&2
  exit 2
fi

SPEC_PATH="$1"

if [ ! -f "$SPEC_PATH" ]; then
  echo "ERROR: spec file not found: $SPEC_PATH" >&2
  exit 1
fi

for stage in eng ux sec a11y; do
  workspace="/tmp/spec-review-$stage"
  rm -rf "$workspace"
  mkdir -p "$workspace/round-1" "$workspace/round-2" "$workspace/round-3"
  cp "$SPEC_PATH" "$workspace/SPEC.md"
  echo "Workspace ready: $workspace"
done

lines=$(wc -l < "$SPEC_PATH")
echo
echo "Spec: $SPEC_PATH ($lines lines)"
echo "Ready to run claude-build-hardening."
