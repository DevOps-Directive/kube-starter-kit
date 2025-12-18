#!/usr/bin/env bash
# Resolve stack IDs to their directory paths
#
# Usage: resolve-stack-ids.sh <search-directory> [stack-ids]
# Arguments:
#   search-directory: Directory tree to search for stack.tm.hcl files
#   stack-ids: Newline-separated list of stack IDs to resolve (or pass via stdin)
# Output: Newline-separated list of stack paths (relative to repo root)
#
# Example:
#   echo -e "staging-use2-eks\nstaging-use2-networking" | \
#     ./resolve-stack-ids.sh terraform/live/staging
#   # Output:
#   # terraform/live/staging/us-east-2/eks
#   # terraform/live/staging/us-east-2/networking

set -euo pipefail

SEARCH_DIR="${1:?Usage: $0 <search-directory> [stack-ids]}"
STACK_IDS="${2:-$(cat)}"  # Read from arg or stdin

if [[ ! -d "$SEARCH_DIR" ]]; then
  echo "ERROR: Directory not found: $SEARCH_DIR" >&2
  exit 1
fi

[[ -z "$STACK_IDS" ]] && exit 0

# Build mapping file: "stack_id|stack_path" per line
# This avoids bash 4+ associative arrays for portability
MAPPING_FILE=$(mktemp)
trap 'rm -f "$MAPPING_FILE"' EXIT

while IFS= read -r stack_file; do
  # Extract stack ID from: id = "some-stack-id"
  # Using POSIX-compatible patterns
  stack_id=$(grep -E 'id[[:space:]]*=[[:space:]]*"[^"]+"' "$stack_file" 2>/dev/null \
    | head -1 \
    | sed 's/.*"\([^"]*\)".*/\1/' \
    || true)

  if [[ -n "$stack_id" ]]; then
    stack_path=$(dirname "$stack_file")
    echo "${stack_id}|${stack_path}" >> "$MAPPING_FILE"
  fi
done < <(find "$SEARCH_DIR" -name 'stack.tm.hcl' -type f)

# Resolve each requested ID to its path
ERRORS=0
while IFS= read -r id; do
  [[ -z "$id" ]] && continue

  # Look up the ID in our mapping file
  path=$(grep "^${id}|" "$MAPPING_FILE" | head -1 | cut -d'|' -f2 || true)

  if [[ -z "$path" ]]; then
    echo "ERROR: Could not resolve stack ID: $id" >&2
    ERRORS=$((ERRORS + 1))
  else
    echo "$path"
  fi
done <<< "$STACK_IDS"

if [[ $ERRORS -gt 0 ]]; then
  exit 1
fi
