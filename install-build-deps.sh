#!/bin/bash
# Install build dependencies for snd-hda-codec-cs8409 Debian package

set -e

echo "Installing build dependencies for snd-hda-codec-cs8409..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y debhelper dh-dkms dkms build-essential \
        linux-headers-$(uname -r) dpkg-sig gnupg
elif command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y debhelper dh-dkms dkms build-essential \
        linux-headers-$(uname -r) dpkg-sig gnupg
else
    echo "Error: apt/apt-get not found. This script is for Debian/Ubuntu systems."
    exit 1
fi

echo ""
echo "Build dependencies installed successfully!"
echo ""
echo "Installed packages:"
echo "  - debhelper, dh-dkms: Debian packaging"
echo "  - dkms: Dynamic Kernel Module System"
echo "  - build-essential: Compiler toolchain"
echo "  - linux-headers: Kernel headers"
echo "  - dpkg-sig, gnupg: Package signing"
echo ""
echo "To build the .deb package, run:"
echo "  dpkg-buildpackage -us -uc -b"
echo ""
echo "To build and create a signed GitHub release:"
echo "  ./scripts/setup-gpg-signing.sh   # One-time setup"
echo "  GPG_KEY_ID=YOUR_KEY ./scripts/build-and-release.sh 1.0"
echo ""
echo "To install the resulting package:"
echo "  sudo dpkg -i ../snd-hda-codec-cs8409-dkms_1.0-1_all.deb"
