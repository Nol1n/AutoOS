#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for development environment on Ubuntu 24.04 LTS
# Safe, idempotent. Run as a normal user (sudo will be used where needed).

echo "== OpenClaw bootstrap =="

sudo apt-get update
sudo apt-get install -y build-essential git python3-venv python3-pip curl \
    qemu-kvm libvirt-daemon-system libvirt-clients virtinst virt-manager \
    swtpm seavgabash || true

python3 -m venv .venv || true
echo "Bootstrap done. Activate with: source .venv/bin/activate"
