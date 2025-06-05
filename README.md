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
- Flutter 3.32+ (managed via FVM)
- Dart 3.8.1+
- iOS development: Xcode 15+ for iOS 17+ target
- Android development: Android Studio with SDK 34

### Getting Started
```bash
# Install FVM if not already installed
dart pub global activate fvm

# Use the pinned Flutter version
fvm use stable

# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run
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