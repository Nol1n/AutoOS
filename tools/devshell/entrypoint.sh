#!/usr/bin/env bash
set -euo pipefail
if [ -f "/workspace/.venv/bin/activate" ]; then
    source /workspace/.venv/bin/activate
fi
exec bash
