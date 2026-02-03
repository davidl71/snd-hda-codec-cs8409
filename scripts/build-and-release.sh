#!/bin/bash
# Build, sign, and create GitHub release for snd-hda-codec-cs8409
# Usage: ./scripts/build-and-release.sh [version]

set -e

VERSION="${1:-1.0}"
PACKAGE_NAME="snd-hda-codec-cs8409-dkms"
GPG_KEY_ID="${GPG_KEY_ID:-}"  # Set this or pass as env var

echo "=== Building ${PACKAGE_NAME} version ${VERSION} ==="

# Check for required tools
for cmd in dpkg-buildpackage gh; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is required but not installed."
        exit 1
    fi
done

# Check for signing tools
HAS_GPG=0
if command -v gpg &> /dev/null; then
    HAS_GPG=1
fi

# Update version in changelog if needed
CURRENT_VERSION=$(head -1 debian/changelog | grep -oP '\(\K[^)]+')
if [ "$CURRENT_VERSION" != "${VERSION}-1" ]; then
    echo "Updating changelog to version ${VERSION}-1..."
    dch -v "${VERSION}-1" "Release version ${VERSION}"
fi

# Clean and build
echo "Building package..."
dpkg-buildpackage -us -uc -b

# Sign the .deb file with GPG detached signature
DEB_FILE="../${PACKAGE_NAME}_${VERSION}-1_all.deb"
SIG_FILE="${DEB_FILE}.asc"
if [ "$HAS_GPG" -eq 1 ] && [ -n "$GPG_KEY_ID" ]; then
    echo "Creating GPG signature with key ${GPG_KEY_ID}..."
    gpg --armor --detach-sign --default-key "$GPG_KEY_ID" -o "$SIG_FILE" "$DEB_FILE"
    echo "Signature created: ${SIG_FILE}"
elif [ -n "$GPG_KEY_ID" ]; then
    echo "Warning: gpg not installed, skipping package signing"
else
    echo "Note: GPG_KEY_ID not set, skipping package signing"
    SIG_FILE=""
fi

# Build list of files to upload
UPLOAD_FILES="$DEB_FILE"
if [ -n "$SIG_FILE" ] && [ -f "$SIG_FILE" ]; then
    UPLOAD_FILES="$UPLOAD_FILES $SIG_FILE"
fi

# Create GitHub release (use origin remote, not upstream)
REPO_NAME="$(git remote get-url origin | sed 's/.*github.com[:\/]\(.*\)\.git/\1/')"
echo "Creating GitHub release v${VERSION} on ${REPO_NAME}..."
gh release create "v${VERSION}" --repo "$REPO_NAME" \
    --title "snd-hda-codec-cs8409 v${VERSION}" \
    --notes "## Installation

### Quick Install (Debian/Ubuntu)
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/${REPO_NAME}/master/scripts/install-repo.sh | sudo bash
\`\`\`

### Manual Install
Download the .deb file and install:
\`\`\`bash
sudo dpkg -i ${PACKAGE_NAME}_${VERSION}-1_all.deb
\`\`\`

## Verification
If a .asc signature file is provided, verify with:
\`\`\`bash
gpg --verify ${PACKAGE_NAME}_${VERSION}-1_all.deb.asc ${PACKAGE_NAME}_${VERSION}-1_all.deb
\`\`\`

## Changes
- Kernel 6.17+ compatibility
- DKMS support for automatic rebuilds
" \
    $UPLOAD_FILES

echo ""
echo "=== Release v${VERSION} created successfully! ==="
echo "View at: https://github.com/davidl71/snd-hda-codec-cs8409/releases/tag/v${VERSION}"
