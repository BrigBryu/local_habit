# Habit Level Up

A cross-platform habit tracker that gamifies personal development through XP progression and level-based UI evolution.

## Iteration 0: Foundation - "Hello Habit"

**Purpose**: Compile once, run on both phones with basic infrastructure.

### Deliverables
- ✅ Flutter project scaffold with cross-platform support
- ✅ State management via Riverpod
- ✅ Local persistence setup with Isar
- ✅ Empty "Daily Habits" screen
- ✅ CI pipeline for automated testing
- ✅ iOS 17+ and Android 34+ targets

### User Stories
- As a user I can open the app and see an empty "Daily Habits" list
- As a dev I get hot-reload & CI for rapid iteration

### Tech Stack
- **Framework**: Flutter 3.32+ with Dart null-safety
- **State Management**: Riverpod v3 for compile-time safe providers
- **Local Database**: Isar for fast, encrypted persistence
- **Platforms**: iOS 17+, Android 34+ (API level 21+)

## Development Setup

### Prerequisites
- Flutter 3.32+ (managed via FVM) ✅
- Dart 3.8.1+ ✅
- Java OpenJDK 21+ ✅
- iOS development: Xcode 15+ for iOS 17+ target (⚠️ needs full Xcode install)
- Android development: Android Studio with SDK 34 ✅
- Android Command Line Tools ✅
- CocoaPods for iOS dependencies ✅

### Getting Started
```bash
# Clone the repository
git clone git@github.com:BrigBryu/habit_level_up.git
cd habit_level_up

# Install FVM if not already installed
dart pub global activate fvm

# Use the pinned Flutter version
fvm use stable

# Install dependencies
fvm flutter pub get

# Run the app (Android requires emulator or device)
fvm flutter run
```

### Android Development Status ✅
- **Android Studio 2024.3** installed
- **Java OpenJDK 21** configured  
- **Android Command Line Tools** installed via Homebrew
- **Android SDK API 34** with platform-tools, build-tools
- **Pixel 8 API 34 emulator** created and functional
- **Flutter doctor** passes for Android toolchain

### Testing the App
```bash
# Start Android emulator
fvm flutter emulators --launch Pixel_8_API_34

# Run the app (or use convenience script)
fvm flutter run -d emulator-5554
# OR
./flutter.sh run -d emulator-5554
```

### Project Structure
```
lib/
├── main.dart                 # App entry point with ProviderScope
├── pages/
│   └── daily_habits_page.dart  # Main habits list screen
└── providers/
    └── habits_provider.dart    # Placeholder habits provider
```

## Roadmap

### Iteration 1: Solo Core Loop (Level-Up mechanics)
- Add/edit/archive habits
- XP system with completion tracking
- Level-based progression gates

### Iteration 2: Dynamic UI (Evolving World)
- Theme engine with level-based visual changes
- Smooth animations for level-up moments
- A/B testing framework

### Iteration 3: Habit Safety Nets (Streak Shield)
- Local push notifications
- Grace period for streak protection
- Time-zone aware reset logic

### Future Iterations
- Partner accountability system
- Cloud sync and offline support
- Advanced analytics and insights