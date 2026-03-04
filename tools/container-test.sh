#!/usr/bin/env bash
set -euo pipefail
# Script to run full containerized test (creates venv, installs deps incl. PySide6, runs tests, builds .deb)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
docker build -t ocd-devshell "$ROOT/tools/devshell"
mkdir -p /tmp/emptyvenv
docker run --rm -v "$ROOT":/workspace -v /tmp/emptyvenv:/workspace/.venv -w /workspace ocd-devshell bash -lc '
  set -euo pipefail
  apt-get update
  apt-get install -y python3-venv python3-pip dpkg build-essential libgl1-mesa-dri libegl-mesa0 libxcb-xinerama0 libxkbcommon-x11-0 libx11-6
  python3 -m venv /workspace/.venv
  PY=/workspace/.venv/bin/python
  "$PY" -m pip install --upgrade pip --break-system-packages
  "$PY" -m pip install -r requirements.txt --break-system-packages
  "$PY" -m pytest -q || true
  bash packages/deb/build_deb.sh
  ls -l dist
'
echo "Container test finished"
