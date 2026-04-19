#!/bin/sh
# Fast installation of alpine-glibc from latest GitHub release.
# Installs: glibc, glibc-bin, glibc-libs, glibc-i18n
# Post-install scripts automatically configure symlinks and ldconfig.
set -e

# Variables
BASE="https://api.github.com/repos/felix9743/alpine-glibc/releases/latest"
ARCH=$(uname -m)

# Minimal dependency
apk add --no-cache curl

# Create and enter the temporary directory
mkdir -p /tmp/glibc-packages && cd /tmp/glibc-packages

# Get all packages for the current architecture
URLS=$(curl -fsSL "$BASE" | grep browser_download_url | cut -d'"' -f4 | grep "$ARCH")
[ -z "$URLS" ] && { echo "No packages found for $ARCH" >&2; exit 1; }

# Download all packages
for url in $URLS; do
    echo "→ $(basename "$url")"
    curl -fsSL "$url" -o "$(basename "$url")"
done

# Install all packages
apk add --allow-untrusted --no-cache *.apk

# Cleanup
cd ~ && rm -rf /tmp/glibc-packages

# Verification
echo -e "\n✓ alpine-glibc installed. Verification:"
/usr/lib/glibc/bin/ldd --version | head -1
