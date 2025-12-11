#!/bin/bash
set -e

echo "Setting up project dependencies..."

# Install mise tools if mise is available
if command -v mise &> /dev/null; then
  echo "Installing mise tools..."
  mise install --yes 2>/dev/null || true
fi

# Install Go dependencies for backend services
for gomod in services/*/go.mod; do
  if [ -f "$gomod" ]; then
    dir=$(dirname "$gomod")
    echo "Installing Go dependencies in $dir..."
    (cd "$dir" && go mod download 2>/dev/null) || true
  fi
done

# Update Helm dependencies for charts
for chart in kubernetes/src/**/Chart.yaml; do
  if [ -f "$chart" ]; then
    dir=$(dirname "$chart")
    if [ -f "$dir/Chart.lock" ] || grep -q "dependencies:" "$chart" 2>/dev/null; then
      echo "Updating Helm dependencies in $dir..."
      (cd "$dir" && helm dependency update 2>/dev/null) || true
    fi
  fi
done

# Initialize Terraform if .terraform doesn't exist
for tfdir in terraform/*/; do
  if [ -d "$tfdir" ] && [ ! -d "$tfdir.terraform" ]; then
    if ls "$tfdir"*.tf 1>/dev/null 2>&1; then
      echo "Initializing Terraform in $tfdir..."
      (cd "$tfdir" && terraform init -backend=false 2>/dev/null) || true
    fi
  fi
done

echo "Dependency setup complete!"
