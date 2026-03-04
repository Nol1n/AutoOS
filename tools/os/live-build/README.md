# Live-build templates for OpenClaw ISO

This folder contains helper templates and a script to build a non-interactive OpenClaw Ubuntu ISO using `live-build`.

Prerequisites (host Ubuntu):

- Install live-build: `sudo apt-get update && sudo apt-get install -y live-build debootstrap squashfs-tools`
- Run the build script as root or with sudo (some operations need root):

```bash
cd tools/os/live-build
sudo bash build-live.sh
```

What it does:
- copies the repository `iso/` artifacts into the live-build tree
- configures the chroot includes so that `/opt/openclaw` contains the `.deb` packages and `/target` installer gets autoinstall files
- runs `lb config` and `lb build` to produce `live-image.iso` in the current directory

See `build-live.sh` for exact commands and editable variables.
