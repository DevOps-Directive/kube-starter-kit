#!/bin/bash
set -e

curl -fsSL https://mise.run | sh

# Add mise to PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Enable experimental features required by this project
export MISE_EXPERIMENTAL=1
