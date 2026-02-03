#!/bin/bash
# Add snd-hda-codec-cs8409 repository and install the package
# Usage: curl -fsSL https://raw.githubusercontent.com/davidl71/snd-hda-codec-cs8409/master/scripts/install-repo.sh | sudo bash

set -e

REPO_OWNER="davidl71"
REPO_NAME="snd-hda-codec-cs8409"
PACKAGE_NAME="snd-hda-codec-cs8409-dkms"
KEYRING_PATH="/usr/share/keyrings/${REPO_NAME}-archive-keyring.gpg"
SOURCES_LIST="/etc/apt/sources.list.d/${REPO_NAME}.list"

echo "=== Installing ${PACKAGE_NAME} ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (use sudo)"
    exit 1
fi

# Install dependencies
apt-get update
apt-get install -y curl jq dkms

# Get latest release info
echo "Fetching latest release..."
RELEASE_INFO=$(curl -fsSL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest")
VERSION=$(echo "$RELEASE_INFO" | jq -r '.tag_name' | sed 's/^v//')
DEB_URL=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url')

if [ -z "$DEB_URL" ] || [ "$DEB_URL" = "null" ]; then
    echo "Error: Could not find .deb file in latest release"
    exit 1
fi

echo "Latest version: ${VERSION}"
echo "Downloading from: ${DEB_URL}"

# Download and install
TEMP_DEB=$(mktemp --suffix=.deb)
curl -fsSL -o "$TEMP_DEB" "$DEB_URL"

echo "Installing package..."
dpkg -i "$TEMP_DEB" || apt-get install -f -y

# Cleanup
rm -f "$TEMP_DEB"

echo ""
echo "=== Installation complete! ==="
echo ""
echo "The module will be automatically built for your kernel."
echo "To load it now: sudo modprobe snd-hda-codec-cs8409"
echo ""
echo "To update in the future, re-run this script or download"
echo "the latest release from:"
echo "  https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
