#!/usr/bin/env bash
#
# Extract container images from Kubernetes manifests.
#
# Usage:
#   extract-images.sh [--environment <env>] [--additional-file <path>] [--additional-images <json-array>]
#
# Options:
#   --environment       Environment to scan (production, staging, or none)
#   --additional-file   Path to YAML file with additional images (only used when environment != none)
#   --additional-images JSON array of additional images to include
#
# Output:
#   JSON array of unique images to stdout
#
set -euo pipefail

# Defaults
ENVIRONMENT=""
ADDITIONAL_FILE=""
ADDITIONAL_IMAGES="[]"
MANIFESTS_BASE_DIR="kubernetes/rendered"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --additional-file)
      ADDITIONAL_FILE="$2"
      shift 2
      ;;
    --additional-images)
      ADDITIONAL_IMAGES="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Validate environment
if [[ -z "$ENVIRONMENT" ]]; then
  echo "Error: --environment is required" >&2
  exit 1
fi

if [[ "$ENVIRONMENT" != "none" && "$ENVIRONMENT" != "production" && "$ENVIRONMENT" != "staging" ]]; then
  echo "Error: --environment must be 'production', 'staging', or 'none'" >&2
  exit 1
fi

# Collect images
declare -a images=()

# 1. Extract from manifests (if environment != none)
if [[ "$ENVIRONMENT" != "none" ]]; then
  manifest_dir="${MANIFESTS_BASE_DIR}/${ENVIRONMENT}"
  
  if [[ ! -d "$manifest_dir" ]]; then
    echo "Error: Manifest directory not found: $manifest_dir" >&2
    exit 1
  fi
  
  # Extract images from 'image:' and 'imageName:' fields
  # Handles various indentation and optional quotes
  while IFS= read -r img; do
    [[ -n "$img" ]] && images+=("$img")
  done < <(
    grep -rhE '^\s*(image|imageName):\s' "$manifest_dir" 2>/dev/null \
      | sed 's/.*: //' \
      | sed 's/^["'"'"']//' \
      | sed 's/["'"'"']$//' \
      | sed 's/^[[:space:]]*//' \
      | sed 's/[[:space:]]*$//' \
      | grep -v '^$' \
      || true
  )
  
  # 2. Add images from additional file (only when environment != none)
  if [[ -n "$ADDITIONAL_FILE" && -f "$ADDITIONAL_FILE" ]]; then
    while IFS= read -r img; do
      [[ -n "$img" ]] && images+=("$img")
    done < <(yq -r '.images[]? // empty' "$ADDITIONAL_FILE" 2>/dev/null || true)
  fi
fi

# 3. Add images from JSON array input
if [[ "$ADDITIONAL_IMAGES" != "[]" && "$ADDITIONAL_IMAGES" != "" ]]; then
  while IFS= read -r img; do
    [[ -n "$img" ]] && images+=("$img")
  done < <(echo "$ADDITIONAL_IMAGES" | jq -r '.[]? // empty' 2>/dev/null || true)
fi

# Validate we have at least one image
if [[ ${#images[@]} -eq 0 ]]; then
  echo "Error: No images to scan. When environment is 'none', you must provide --additional-images." >&2
  exit 1
fi

# Deduplicate and output as JSON array
# TODO: Remove head -3 after testing - this limits to 3 images for faster test runs
printf '%s\n' "${images[@]}" | sort -u | head -3 | jq -R -s 'split("\n") | map(select(length > 0))'
