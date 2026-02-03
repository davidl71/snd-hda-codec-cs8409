#!/bin/bash
# DKMS installation script for snd-hda-codec-cs8409

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
    echo "DKMS is not installed. Please install it first:"
    echo "  Ubuntu/Debian: sudo apt install dkms"
    echo "  Fedora: sudo dnf install dkms"
    echo "  Arch: sudo pacman -S dkms"
    exit 1
fi

# Remove old installation if exists
if [ -d "$DKMS_DIR" ]; then
    echo "Removing existing installation..."
    dkms remove ${PACKAGE_NAME}/${PACKAGE_VERSION} --all 2>/dev/null || true
    rm -rf "$DKMS_DIR"
fi

# Copy source to DKMS directory
echo "Installing source to ${DKMS_DIR}..."
mkdir -p "$DKMS_DIR"
cp -r ./*.c ./*.h ./Makefile ./dkms.conf "$DKMS_DIR/"

# Add to DKMS
echo "Adding module to DKMS..."
dkms add -m ${PACKAGE_NAME} -v ${PACKAGE_VERSION}

# Build for current kernel
echo "Building module for kernel $(uname -r)..."
dkms build -m ${PACKAGE_NAME} -v ${PACKAGE_VERSION}

# Install
echo "Installing module..."
dkms install -m ${PACKAGE_NAME} -v ${PACKAGE_VERSION}

echo ""
echo "Installation complete!"
echo "The module will be automatically rebuilt for new kernels."
echo ""
echo "To load the module now:"
echo "  sudo modprobe snd-hda-codec-cs8409"
echo ""
echo "To uninstall:"
echo "  sudo dkms remove ${PACKAGE_NAME}/${PACKAGE_VERSION} --all"
echo "  sudo rm -rf ${DKMS_DIR}"
