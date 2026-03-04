#!/usr/bin/env bash
set -euo pipefail
# Helper script to prepare ISO artifacts for OpenClaw Desktop

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
ISO_OUT="$ROOT/dist/iso"
mkdir -p "$ISO_OUT"

echo "Preparing ISO artifacts in $ISO_OUT"

echo "Copying .deb packages into ISO pool..."
mkdir -p "$ISO_OUT/pool/openclaw"
if [ -d "$ROOT/dist" ]; then
  cp -v $ROOT/dist/*.deb "$ISO_OUT/pool/openclaw/" 2>/dev/null || true
fi

echo "Copying firstboot scripts and autoinstall templates"
cp -r "$ROOT/iso/firstboot" "$ISO_OUT/" 2>/dev/null || true
cp -r "$ROOT/iso/autoinstall" "$ISO_OUT/" 2>/dev/null || true

cat <<'EOF'
Next steps (interactive):
 - Launch Cubic (on Ubuntu host) and point to original Ubuntu Desktop ISO
 - In Cubic chroot, copy the contents of $ISO_OUT into the chroot / (e.g. /opt/openclaw, /target/)
 - Ensure /target/etc/cloud or autoinstall files are present
 - Build ISO and test in VM

Non-interactive alternative: use `live-build` and place files under config/includes.chroot/
EOF

echo "Done. See docs/PHASE6_ISO.md for details."
