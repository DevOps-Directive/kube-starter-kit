#!/usr/bin/env bash
# Generate outputs.tm.hcl from a module's outputs.tf
#
# Usage: ./generate-outputs.sh <module_path> <wrapper_name> [output_file]
#
# Examples:
#   ./generate-outputs.sh ../../modules/networking networking
#   ./generate-outputs.sh ../../modules/eks eks outputs.tm.hcl

set -euo pipefail

MODULE_PATH="${1:?Usage: $0 <module_path> <wrapper_name> [output_file]}"
WRAPPER_NAME="${2:?Usage: $0 <module_path> <wrapper_name> [output_file]}"
OUTPUT_FILE="${3:-}"

if [[ ! -f "$MODULE_PATH/outputs.tf" ]]; then
  echo "Error: $MODULE_PATH/outputs.tf not found" >&2
  exit 1
fi

generate_outputs() {
  echo "# Outputs for sharing with dependent stacks"
  echo "# Generated from: $MODULE_PATH/outputs.tf"
  echo ""

  # Parse output blocks from outputs.tf
  grep -E '^output "[^"]+"' "$MODULE_PATH/outputs.tf" | while read -r line; do
    # Extract output name from: output "name" {
    output_name=$(echo "$line" | sed 's/output "\([^"]*\)".*/\1/')
    
    cat <<EOF
output "$output_name" {
  backend = "terraform"
  value   = module.${WRAPPER_NAME}.${output_name}
}

EOF
  done
}

if [[ -n "$OUTPUT_FILE" ]]; then
  generate_outputs > "$OUTPUT_FILE"
  echo "Generated $OUTPUT_FILE with wrapper module.$WRAPPER_NAME" >&2
else
  generate_outputs
fi
