#!/bin/bash
# Build, sign, and create GitHub release for snd-hda-codec-cs8409
# Usage: ./scripts/build-and-release.sh [version]

set -e

VERSION="${1:-1.0}"
PACKAGE_NAME="snd-hda-codec-cs8409-dkms"
GPG_KEY_ID="${GPG_KEY_ID:-}"  # Set this or pass as env var

echo "=== Building ${PACKAGE_NAME} version ${VERSION} ==="

# Check for required tools
for cmd in dpkg-buildpackage gh gpg; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is required but not installed."
        exit 1
    fi
done

# Update version in changelog if needed
CURRENT_VERSION=$(head -1 debian/changelog | grep -oP '\(\K[^)]+')
if [ "$CURRENT_VERSION" != "${VERSION}-1" ]; then
    echo "Updating changelog to version ${VERSION}-1..."
    dch -v "${VERSION}-1" "Release version ${VERSION}"
fi

# Clean and build
echo "Building package..."
dpkg-buildpackage -us -uc -b

# Sign the .deb file
DEB_FILE="../${PACKAGE_NAME}_${VERSION}-1_all.deb"
if [ -n "$GPG_KEY_ID" ]; then
    echo "Signing package with GPG key ${GPG_KEY_ID}..."
    dpkg-sig -k "$GPG_KEY_ID" --sign builder "$DEB_FILE"
else
    echo "Warning: GPG_KEY_ID not set, skipping package signing"
fi

# Create GitHub release
echo "Creating GitHub release v${VERSION}..."
gh release create "v${VERSION}" \
    --title "snd-hda-codec-cs8409 v${VERSION}" \
    --notes "## Installation

### Quick Install (Debian/Ubuntu)
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/davidl71/snd-hda-codec-cs8409/master/scripts/install-repo.sh | sudo bash
sudo apt install snd-hda-codec-cs8409-dkms
\`\`\`

### Manual Install
Download the .deb file and install:
\`\`\`bash
sudo dpkg -i ${PACKAGE_NAME}_${VERSION}-1_all.deb
\`\`\`

## Changes
- Kernel 6.17+ compatibility
- DKMS support for automatic rebuilds
" \
    "$DEB_FILE"

echo ""
echo "=== Release v${VERSION} created successfully! ==="
echo "View at: https://github.com/davidl71/snd-hda-codec-cs8409/releases/tag/v${VERSION}"
