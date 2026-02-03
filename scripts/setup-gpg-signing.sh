#!/bin/bash
# Setup GPG key for signing Debian packages
# Usage: ./scripts/setup-gpg-signing.sh

set -e

echo "=== GPG Key Setup for Package Signing ==="
echo ""

# Check if gpg is installed
if ! command -v gpg &> /dev/null; then
    echo "Installing gnupg..."
    sudo apt-get install -y gnupg
fi

# Check for existing keys
EXISTING_KEYS=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -E "^sec" || true)

if [ -n "$EXISTING_KEYS" ]; then
    echo "Existing GPG keys found:"
    gpg --list-secret-keys --keyid-format LONG
    echo ""
    read -p "Use existing key? (y/n): " USE_EXISTING
    if [ "$USE_EXISTING" = "y" ]; then
        read -p "Enter key ID (e.g., ABCD1234EFGH5678): " GPG_KEY_ID
    fi
fi

if [ -z "$GPG_KEY_ID" ]; then
    echo ""
    echo "Generating new GPG key..."
    echo ""
    
    # Generate key
    cat > /tmp/gpg-key-params <<EOF
%echo Generating GPG key for package signing
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $(git config user.name)
Name-Email: $(git config user.email)
Expire-Date: 2y
%commit
%echo Done
EOF

    gpg --batch --generate-key /tmp/gpg-key-params
    rm /tmp/gpg-key-params
    
    GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep -E "^sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)
fi

echo ""
echo "=== GPG Key Setup Complete ==="
echo ""
echo "Your GPG Key ID: ${GPG_KEY_ID}"
echo ""
echo "Add this to your shell profile (~/.bashrc or ~/.zshrc):"
echo "  export GPG_KEY_ID=\"${GPG_KEY_ID}\""
echo ""
echo "To export your public key for users to verify signatures:"
echo "  gpg --armor --export ${GPG_KEY_ID} > public-key.asc"
echo ""
echo "To sign packages, run:"
echo "  GPG_KEY_ID=${GPG_KEY_ID} ./scripts/build-and-release.sh"
