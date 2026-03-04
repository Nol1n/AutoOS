#!/usr/bin/env bash
set -euo pipefail
pkgdir="./packages/openclaw"
out="./dist"
mkdir -p "$out"
# Ensure maintainer scripts are executable per dpkg-deb requirements
if [ -f "$pkgdir/DEBIAN/postinst" ]; then
	chmod 0755 "$pkgdir/DEBIAN/postinst"
fi
if [ -f "$pkgdir/DEBIAN/postrm" ]; then
	chmod 0755 "$pkgdir/DEBIAN/postrm"
fi
dpkg-deb --build "$pkgdir" "$out/openclaw_0.1.0_all.deb"
echo "Built $out/openclaw_0.1.0_all.deb"
