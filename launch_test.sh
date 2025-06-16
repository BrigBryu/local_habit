#!/bin/bash

# Launch script for automated testing
set -e

echo "🚀 Starting automated habit sync test"

# Clean up any existing processes
pkill -f "flutter run" || true
pkill -f "smoke_test" || true

# Clean up old log files
rm -f frank.log bob.log

# Launch emulators
echo "📱 Launching emulators..."
flutter emulators --launch pixel_2_api_30 || flutter emulators --launch Pixel_2_API_30 || true
flutter emulators --launch pixel_2_api_30_2 || flutter emulators --launch Pixel_2_API_30_2 || true

# Wait for emulators to be ready
echo "⏳ Waiting for emulators to boot..."
sleep 30

# Check available devices
echo "🔍 Available devices:"
flutter devices

# Launch Bob's app
echo "👤 Starting Bob's app (emulator-5556)..."
TEST_USER_OVERRIDE=bob@test.com flutter run -d emulator-5556 --no-sound-null-safety -v > bob.log 2>&1 &
BOB_PID=$!

# Launch Frank's app  
echo "👤 Starting Frank's app (emulator-5554)..."
TEST_USER_OVERRIDE=frank@test.com flutter run -d emulator-5554 --no-sound-null-safety -v > frank.log 2>&1 &
FRANK_PID=$!

# Launch smoke test
echo "🧪 Starting smoke test..."
dart run tool/smoke_test.dart &
TEST_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "🧽 Cleaning up processes..."
    kill $BOB_PID $FRANK_PID $TEST_PID 2>/dev/null || true
    exit 0
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Wait for smoke test to complete
wait $TEST_PID
SMOKE_RESULT=$?

if [ $SMOKE_RESULT -eq 0 ]; then
    echo "🌙 All fixes applied, apps running"
else
    echo "❌ Smoke test failed"
    exit 1
fi