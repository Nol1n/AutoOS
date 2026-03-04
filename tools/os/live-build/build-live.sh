#!/usr/bin/env bash
set -euo pipefail
# Build script for live-build based ISO for OpenClaw
# Edit variables below as needed

# If not running as root, re-exec this script under sudo so debootstrap/chroot
# operations (which require root) succeed. This makes the script robust when
# invoked from CI steps that forget to use sudo.
if [ "${EUID-$(id -u)}" -ne 0 ]; then
  echo "Not running as root — re-executing under sudo"
  exec sudo "$0" "$@"
fi

# Basic diagnostics to help CI debugging
echo "uid=$(id -u) $(id)"
echo "hostname:$(hostname)  uname:$(uname -a)"

LB_WORKDIR=$(pwd)/live-build-work
ISO_OUT=$(pwd)/live-image.iso
REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)

# Shell-level defaults used by lb config
LB_DISTRIBUTION="jammy"
LB_MIRROR_HTTP="http://archive.ubuntu.com/ubuntu/"
LB_ARCH="amd64"

echo "Live-build workdir: $LB_WORKDIR"
rm -rf "$LB_WORKDIR"
mkdir -p "$LB_WORKDIR"
cd "$LB_WORKDIR"

# Copy includes: files to be merged into the chroot or installer
mkdir -p includes.chroot/opt/openclaw
mkdir -p includes.installer

echo "Copying .deb packages (if any) into includes.chroot/opt/openclaw"
if [ -d "$REPO_ROOT/dist" ]; then
  cp -v $REPO_ROOT/dist/*.deb includes.chroot/opt/openclaw/ 2>/dev/null || true
fi

echo "Copying autoinstall files into includes.installer"
if [ -d "$REPO_ROOT/iso/autoinstall" ]; then
  cp -v -r $REPO_ROOT/iso/autoinstall/* includes.installer/ 2>/dev/null || true
fi


# ensure auto dir exists for lb auto config
mkdir -p auto


# Create a simple auto/config that exports the expected LB_* variables with literal values
# Use an unquoted heredoc so shell variables are expanded now and the generated script contains
# concrete values (live-build executes auto/config in a clean environment).
cat > auto/config <<EOF
#!/usr/bin/env bash
export LB_DISTRIBUTION="$LB_DISTRIBUTION"
export LB_MIRROR_HTTP="$LB_MIRROR_HTTP"
export LB_MIRROR_SUITE="$LB_DISTRIBUTION"
export LB_MIRROR_COMPONENTS="main universe multiverse restricted"
export LB_ARCH="$LB_ARCH"
export LB_ARCHES="$LB_ARCH"
EOF

chmod +x auto/config || true

echo "Configuring lb (distribution: $LB_DISTRIBUTION)"

# Ensure a config/bootstrap exists before running lb config so lb cannot fall back to defaults
mkdir -p config/bootstrap
echo "$LB_DISTRIBUTION" > config/bootstrap/suite
cat > config/bootstrap/archives <<EOL
deb $LB_MIRROR_HTTP $LB_DISTRIBUTION main universe multiverse restricted
EOL

# Remove any leftover live-build cache to avoid restoring an old bootstrap (may require root)
if [ -d /var/cache/live-build ]; then
  rm -rf /var/cache/live-build/* || true
fi

# Run lb config with explicit architecture and mirror-bootstrap to ensure correct bootstrap suite
lb config \
  --distribution "$LB_DISTRIBUTION" \
  --architecture "$LB_ARCH" \
  --archive-areas "main universe multiverse" \
  --binary-images iso-hybrid \
  --mirror-bootstrap "$LB_MIRROR_HTTP" || true

# Debug: show what config/ and auto/ contain before building
echo "--- auto/ listing ---"
ls -la auto || true
echo "--- auto/config content ---"
sed -n '1,200p' auto/config || true
echo "--- config/ listing ---"
ls -la config || true

echo "Building ISO (this may take a while)"
# If lb didn't create a config/ tree, provide a minimal fallback so bootstrap uses Ubuntu
if [ ! -d config ]; then
  echo "No config/ created by lb; writing minimal config/bootstrap to force jammy bootstrap"
  mkdir -p config/bootstrap
  echo "$LB_DISTRIBUTION" > config/bootstrap/suite
  cat > config/bootstrap/archives <<EOL
deb $LB_MIRROR_HTTP $LB_DISTRIBUTION main universe multiverse restricted
EOL
  echo "Wrote config/bootstrap/suite and archives"
fi

  # Debug: show and clear any existing live-build cache in the workdir to avoid restoring an old bootstrap
  echo "--- pre-build cache listing (workdir) ---"
  ls -la cache || true
  echo "--- clearing local workdir cache ---"
  rm -rf cache || true

  # Also clear system live-build cache if present
  echo "--- clearing /var/cache/live-build ---"
  rm -rf /var/cache/live-build/* 2>/dev/null || true

  # As a fallback, perform an explicit debootstrap for the desired Ubuntu suite so
  # the chroot is populated correctly (prevents accidental Debian wheezy bootstrap).
  if [ ! -d chroot ] || [ -z "$(ls -A chroot 2>/dev/null || true)" ]; then
    echo "Chroot empty; running explicit debootstrap for $LB_DISTRIBUTION"
    debootstrap --arch="$LB_ARCH" --variant=minbase "$LB_DISTRIBUTION" chroot "$LB_MIRROR_HTTP" || true
    echo "Explicit debootstrap complete; debootstrap log:" || true
    sed -n '1,120p' chroot/debootstrap/debootstrap.log || true
  fi

  lb build

if [ -f binary-image.iso ]; then
  mv binary-image.iso "$ISO_OUT"
  echo "ISO built: $ISO_OUT"
else
  echo "ISO build failed: binary-image.iso not found" >&2
  exit 1
fi
