#!/bin/zsh
set -e
VAULT="/Users/davechow/Documents/Local/Master Vault/02-Projects/SixDoku/SixDoku - Project Home/Specs"
DEST="docs/Specs"
echo "Syncing vault Specs → $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$VAULT/." "$DEST/"
# Also sync bootstrap prompt + README for reference
mkdir -p docs
cp "/Users/davechow/Documents/Local/Master Vault/06-Templates/OpenCodeBootstrapPrompt.md.md" docs/OpenCodeBootstrapPrompt.md 2>/dev/null || true
cp "/Users/davechow/Documents/Local/Master Vault/02-Projects/SixDoku/SixDoku - Project Home/README.md.md" docs/README.vault.md 2>/dev/null || true
echo "Done. Files:"
find docs -type f | sort
