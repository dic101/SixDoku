#!/bin/bash
# Regenerates bundled SeedCatalog.json for iOS + watch apps.
# Usage: ./scripts/seed-catalog.sh [perBucket=8]
set -euo pipefail
cd "$(dirname "$0")/.."
PER_BUCKET="${1:-8}"
swift build --product SeedGenerator
./.build/debug/SeedGenerator "$PER_BUCKET" iOSApp/Resources/SeedCatalog.json
mkdir -p WatchApp/Resources
cp iOSApp/Resources/SeedCatalog.json WatchApp/Resources/SeedCatalog.json
echo "Seeded $PER_BUCKET per bucket ($((2 * 3 * PER_BUCKET)) total) → iOSApp/Resources + WatchApp/Resources"
