#!/usr/bin/env bash
# Extract from_stack_id values from input blocks in terramate configs
#
# Usage: get-sharing-dependencies.sh <base-directory> [stack-paths]
# Arguments:
#   base-directory: Base directory for stack paths (e.g., terraform/live/staging)
#   stack-paths: Newline-separated list of relative stack paths to scan (or pass via stdin)
#                If not provided, scans all stacks in base-directory
# Output: Newline-separated list of unique stack IDs that the specified stacks
#         depend on for output sharing
#
# Examples:
#   # Scan specific stacks (pass paths as argument)
#   ./get-sharing-dependencies.sh terraform/live/staging "us-east-2/services/go-backend"
#
#   # Scan specific stacks (pass paths via stdin)
#   echo "us-east-2/services/go-backend" | ./get-sharing-dependencies.sh terraform/live/staging
#
#   # Scan all stacks in directory (no stack paths provided)
#   ./get-sharing-dependencies.sh terraform/live/staging

set -euo pipefail

BASE_DIR="${1:?Usage: $0 <base-directory> [stack-paths]}"

if [[ ! -d "$BASE_DIR" ]]; then
  echo "ERROR: Directory not found: $BASE_DIR" >&2
  exit 1
fi

# Get stack paths from argument or stdin, if provided
STACK_PATHS="${2:-}"
if [[ -z "$STACK_PATHS" ]] && [[ ! -t 0 ]]; then
  # Read from stdin if it's not a terminal (i.e., piped input)
  STACK_PATHS=$(cat)
fi

if [[ -n "$STACK_PATHS" ]]; then
  # Scan only the specified stack directories
  while IFS= read -r stack_path; do
    [[ -z "$stack_path" ]] && continue
    full_path="${BASE_DIR}/${stack_path}"
    if [[ -d "$full_path" ]]; then
      grep -rh 'from_stack_id[[:space:]]*=' "$full_path" --include='*.tm.hcl' 2>/dev/null || true
    fi
  done <<< "$STACK_PATHS"
else
  # Scan entire base directory
  grep -rh 'from_stack_id[[:space:]]*=' "$BASE_DIR" --include='*.tm.hcl' 2>/dev/null || true
fi \
  | sed -n 's/.*from_stack_id[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' \
  | sort -u
