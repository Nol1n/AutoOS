#!/usr/bin/env bash
set -euo pipefail
# First-boot installer for OpenClaw Desktop
# Installs local .deb packages placed under /opt/openclaw

LOG=/var/log/openclaw/firstboot.log
mkdir -p /var/log/openclaw
exec >> "$LOG" 2>&1

echo "Starting OpenClaw firstboot at $(date)"

if [ -d /opt/openclaw ]; then
  echo "Installing local .deb packages..."
  dpkg -i /opt/openclaw/*.deb || apt-get -fy install -y
fi

echo "Enabling services..."
if systemctl list-unit-files | grep -q openclawd.service; then
  systemctl enable --now openclawd.service || true
fi
if systemctl list-unit-files | grep -q openclaw-shell.service; then
  systemctl enable --now openclaw-shell.service || true
fi

echo "Firstboot completed at $(date)"
