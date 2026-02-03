#!/bin/bash
# DKMS uninstallation script for snd-hda-codec-cs8409

set -e

PACKAGE_NAME="snd-hda-codec-cs8409"
PACKAGE_VERSION="1.0"
DKMS_DIR="/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if dkms is installed
if ! command -v dkms &> /dev/null; then
    echo "DKMS is not installed."
    exit 1
fi

# Unload module if loaded
if lsmod | grep -q "snd_hda_codec_cs8409"; then
    echo "Unloading module..."
    modprobe -r snd_hda_codec_cs8409 || true
fi

# Remove from DKMS
echo "Removing module from DKMS..."
dkms remove ${PACKAGE_NAME}/${PACKAGE_VERSION} --all 2>/dev/null || true

# Remove source directory
if [ -d "$DKMS_DIR" ]; then
    echo "Removing source directory..."
    rm -rf "$DKMS_DIR"
fi

echo "Uninstallation complete!"
