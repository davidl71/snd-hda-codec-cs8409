#!/bin/bash
# Install build dependencies for snd-hda-codec-cs8409 Debian package

set -e

echo "Installing build dependencies for snd-hda-codec-cs8409..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y debhelper dh-dkms dkms build-essential linux-headers-$(uname -r)
elif command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y debhelper dh-dkms dkms build-essential linux-headers-$(uname -r)
else
    echo "Error: apt/apt-get not found. This script is for Debian/Ubuntu systems."
    exit 1
fi

echo ""
echo "Build dependencies installed successfully!"
echo ""
echo "To build the .deb package, run:"
echo "  dpkg-buildpackage -us -uc -b"
echo ""
echo "To install the resulting package:"
echo "  sudo dpkg -i ../snd-hda-codec-cs8409-dkms_1.0-1_all.deb"
