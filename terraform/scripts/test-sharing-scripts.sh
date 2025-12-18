#!/usr/bin/env bash
# Test the sharing dependency scripts
#
# Usage: test-sharing-scripts.sh
# Runs a series of tests against get-sharing-dependencies.sh and resolve-stack-ids.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Testing get-sharing-dependencies.sh ==="
echo

echo "1. Scan all stacks (no paths provided):"
"$SCRIPT_DIR/get-sharing-dependencies.sh" live/staging
echo

echo "2. Scan specific stack (go-backend):"
echo "us-east-2/services/go-backend" | "$SCRIPT_DIR/get-sharing-dependencies.sh" live/staging
echo

echo "3. Scan specific stack (eks):"
echo "us-east-2/eks" | "$SCRIPT_DIR/get-sharing-dependencies.sh" live/staging
echo

echo "=== Testing resolve-stack-ids.sh ==="
echo

echo "1. Resolve single ID:"
echo "staging-use2-eks" | "$SCRIPT_DIR/resolve-stack-ids.sh" live/staging
echo

echo "2. Resolve multiple IDs:"
echo -e "staging-use2-eks\nstaging-use2-networking" | "$SCRIPT_DIR/resolve-stack-ids.sh" live/staging
echo

echo "All tests passed!"
