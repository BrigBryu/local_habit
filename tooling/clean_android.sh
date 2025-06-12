#!/usr/bin/env bash
set -e
# Use available Flutter (system or repo-local)
if [ -f "$(pwd)/flutter/bin/flutter" ]; then
    FLUTTER_BIN="$(pwd)/flutter/bin/flutter"
else
    FLUTTER_BIN="flutter"
fi
echo "🧹 flutter clean…"
"$FLUTTER_BIN" clean
echo "🧹 removing Gradle & Dart tool caches…"
rm -rf ~/.gradle/caches android/.gradle build .dart_tool
echo "✅ Clean complete"