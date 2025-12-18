#!/usr/bin/env bash
# List all stacks needing init (changed + their sharing dependencies)
#
# Usage: list-stacks-to-init.sh [base-directory]
# Arguments:
#   base-directory: Base directory for stacks (default: live/staging)
# Output: Displays changed stacks, their sharing dependencies, and the final
#         list of stacks that need to be initialized
#
# Example:
#   ./list-stacks-to-init.sh live/staging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${1:-live/staging}"

# Get changed stacks
CHANGED=$(terramate list -C "$DIR" --changed 2>/dev/null || true)

if [[ -z "$CHANGED" ]]; then
  echo "No changed stacks found"
  exit 0
fi

echo "=== Changed stacks ==="
echo "$CHANGED"
echo

# Get sharing dependencies (only for changed stacks)
SHARING_DEPS=$(echo "$CHANGED" | "$SCRIPT_DIR/get-sharing-dependencies.sh" "$DIR")

echo "=== Sharing dependency stack IDs ==="
echo "$SHARING_DEPS"
echo

# Get changed stack IDs
CHANGED_IDS=""
while IFS= read -r stack_path; do
  [[ -z "$stack_path" ]] && continue
  id=$(terramate -C "$DIR/$stack_path" experimental get-config-value terramate.stack.id 2>/dev/null || true)
  if [[ -n "$id" ]]; then
    CHANGED_IDS+="$id"$'\n'
  fi
done <<< "$CHANGED"

echo "=== Changed stack IDs ==="
echo "$CHANGED_IDS"
echo

# Combine and dedupe all IDs
ALL_IDS=$(echo -e "${CHANGED_IDS}${SHARING_DEPS}" | sort -u | grep -v '^$' || true)

echo "=== All unique stack IDs (changed + deps) ==="
echo "$ALL_IDS"
echo

# Resolve to paths
echo "=== Stacks to initialize ==="
echo "$ALL_IDS" | "$SCRIPT_DIR/resolve-stack-ids.sh" "$DIR"
