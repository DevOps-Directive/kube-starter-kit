#!/bin/bash
set -e

# Install mise tools at session start
# Other dependencies (Go, Helm, Terraform) install on-demand during execution
if command -v mise &> /dev/null; then
  echo "Installing mise tools..."
  mise install --yes 2>/dev/null || true
  echo "Mise tools ready"
else
  echo "Warning: mise not found, some tools may be unavailable"
fi
