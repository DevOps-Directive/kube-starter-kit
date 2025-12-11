#!/bin/bash
set -e

# Get the file that was edited from Claude hook input
if [ -n "$CLAUDE_HOOK_INPUT" ]; then
  EDITED_FILE=$(echo "$CLAUDE_HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.file_paths[0] // empty' 2>/dev/null)
fi

# Exit early if we couldn't determine the file
if [ -z "$EDITED_FILE" ]; then
  exit 0
fi

# Get the directory of the edited file
EDIT_DIR=$(dirname "$EDITED_FILE")

# Handle Go dependency files
if [[ "$EDITED_FILE" == *"go.mod" ]] || [[ "$EDITED_FILE" == *"go.sum" ]]; then
  echo "Go dependencies changed, running go mod tidy..."
  (cd "$EDIT_DIR" && go mod tidy 2>/dev/null) || true
fi

# Handle Helm Chart changes
if [[ "$EDITED_FILE" == *"Chart.yaml" ]]; then
  echo "Helm Chart changed, updating dependencies..."
  (cd "$EDIT_DIR" && helm dependency update 2>/dev/null) || true
fi

# Handle Terraform changes
if [[ "$EDITED_FILE" == *.tf ]]; then
  echo "Terraform file changed, running fmt and validate..."
  (cd "$EDIT_DIR" && terraform fmt "$EDITED_FILE" 2>/dev/null) || true
  if [ -d "$EDIT_DIR/.terraform" ]; then
    (cd "$EDIT_DIR" && terraform validate 2>/dev/null) || true
  fi
fi

# Handle mise.toml changes
if [[ "$EDITED_FILE" == *"mise.toml" ]]; then
  echo "mise.toml changed, installing tools..."
  (cd "$EDIT_DIR" && mise install --yes 2>/dev/null) || true
fi
