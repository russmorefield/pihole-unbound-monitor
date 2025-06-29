#!/bin/bash

# bump-version.sh - Bumps the version in version.txt and pushes the tag to GitHub

set -e

VERSION_FILE="version.txt"

if [ ! -f "$VERSION_FILE" ]; then
    echo "0.1.0" > "$VERSION_FILE"
    echo "Initialized version.txt with 0.1.0"
fi

# Read the current version
CURRENT_VERSION=$(cat "$VERSION_FILE")
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Default: bump patch version
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Write new version to version.txt
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "Bumped version: $CURRENT_VERSION → $NEW_VERSION"

# Commit and tag
git add "$VERSION_FILE"
git commit -m "chore: bump version to $NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
git push origin main
git push origin "v$NEW_VERSION"
echo "Version bumped and pushed to GitHub: v$NEW_VERSION"