#!/bin/bash

# Clean Android Build Script
# Forces fresh debug & release APKs that match Chrome/web behavior
# Usage: ./tooling/clean_android_build.sh [debug|release]

set -e  # Exit on any error

echo "🧹 Starting comprehensive Android build cleanup..."

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Ensure we use repo-local Flutter SDK
export PATH="$PROJECT_ROOT/flutter/bin:$PATH"
echo "✅ Using Flutter SDK: $(which flutter)"
echo "   Flutter version: $(flutter --version --machine | head -n1)"

# Clean all build artifacts
echo "🗑️  Removing build artifacts..."
rm -rf build/
rm -rf android/app/build/
rm -rf android/build/
rm -rf android/.gradle/
rm -rf ~/.gradle/caches/

# Clean Flutter caches
echo "🗑️  Cleaning Flutter caches..."
flutter clean

# Clean pub cache and re-get dependencies
echo "📦 Refreshing dependencies..."
rm -rf .dart_tool/
rm -rf pubspec.lock
flutter pub get

# Clear Android local properties that might point to wrong SDK
echo "🔧 Resetting Android configuration..."
rm -f android/local.properties

# Regenerate Android local.properties with correct paths
echo "🔧 Regenerating Android local.properties..."
flutter build apk --debug --dry-run 2>/dev/null || true

# Kill any running Gradle daemons
echo "🛑 Stopping Gradle daemons..."
./android/gradlew --stop 2>/dev/null || true
killall -9 java 2>/dev/null || true

# Verify current lib/main.dart exists and is valid
echo "🔍 Verifying main.dart..."
if [ ! -f "lib/main.dart" ]; then
    echo "❌ ERROR: lib/main.dart not found!"
    exit 1
fi

# Check syntax
echo "🔍 Checking Dart syntax..."
flutter analyze lib/main.dart || {
    echo "❌ ERROR: lib/main.dart has syntax errors!"
    exit 1
}

# Build type selection
BUILD_TYPE="${1:-debug}"
case "$BUILD_TYPE" in
    "debug")
        echo "🔨 Building fresh debug APK..."
        flutter build apk --debug --verbose
        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    "release")
        echo "🔨 Building fresh release APK..."
        flutter build apk --release --verbose
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        ;;
    *)
        echo "❌ Invalid build type: $BUILD_TYPE"
        echo "Usage: $0 [debug|release]"
        exit 1
        ;;
esac

# Verify APK was created
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "✅ Fresh $BUILD_TYPE APK created successfully!"
    echo "   Path: $APK_PATH"
    echo "   Size: $APK_SIZE"
    
    # Show APK info
    echo "📱 APK Information:"
    aapt dump badging "$APK_PATH" 2>/dev/null | grep -E "package:|versionCode:|versionName:" || echo "   (aapt not available)"
else
    echo "❌ ERROR: APK build failed! Expected: $APK_PATH"
    exit 1
fi

# Optional: Install to connected device
if command -v adb >/dev/null 2>&1; then
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
    if [ "$DEVICES" -gt 0 ]; then
        echo "📱 Found $DEVICES Android device(s). Install APK? (y/N)"
        read -r -n 1 INSTALL_CHOICE
        echo
        if [[ "$INSTALL_CHOICE" =~ ^[Yy]$ ]]; then
            echo "📲 Installing APK..."
            adb install -r "$APK_PATH"
            echo "✅ APK installed successfully!"
        fi
    fi
else
    echo "💡 Tip: Install adb to automatically install the APK to connected devices"
fi

echo "🎉 Android build cleanup and rebuild complete!"
echo "   APK: $APK_PATH"
echo "   This APK should now match the current Chrome/web behavior."