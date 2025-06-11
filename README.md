# Habit Level Up 🚀

A professional Flutter habit tracking app built with clean architecture, future-proof design, and gamified personal development.

## 🏗️ Professional Architecture

**Clean Architecture with Sealed Class Hierarchy:**

```
habit_level_up/
├─ packages/
│   ├─ domain/           ← Pure Dart: Sealed Habit entities, use cases
│   ├─ data_local/       ← Isar persistence with discriminator pattern
│   ├─ data_remote/      ← Future: Firebase/Supabase sync
│   └─ features/         ← Future: Modular features
├─ app/                  ← Flutter UI entry point
├─ melos.yaml           ← Workspace management
└─ .fvm/                ← Flutter version pinning
```

**Key Benefits:**
- ✅ **Version pinned** with FVM + locked dependencies
- ✅ **Domain separated** from framework (pure Dart)
- ✅ **Sealed classes** for compiler-safe polymorphism
- ✅ **Future-proof** habit variants (basic → timed → scored)
- ✅ **Local-first** with sync queue ready
- ✅ **Automated tooling** (melos scripts)

## 🚀 Getting Started with Android Studio

### Prerequisites
- **Flutter SDK 3.24.5** (managed via FVM)
- **Android Studio 2024.3+** with Android SDK 34
- **Java OpenJDK 21+**
- **Git**

### 📋 Setup Instructions

#### 1. **Environment Configuration**
Copy `.env.example` to `.env` and configure your Supabase credentials:
```bash
cp .env.example .env
```

Then edit `.env` with your actual Supabase values:
```
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
TEST_EMAIL=test@example.com
TEST_PASSWORD=secret123
```

#### 2. **Clone and Setup Workspace**
```bash
cd habit_level_up

# Install FVM for Flutter version management
dart pub global activate fvm
fvm install 3.24.5
fvm use 3.24.5

# Install Melos for workspace management
dart pub global activate melos
```

#### 2. **Bootstrap Dependencies**
```bash
# Bootstrap all packages in the workspace
melos bootstrap

# Generate required freezed/json_serializable code
cd packages/domain
dart run build_runner build

cd ../data_local  
dart run build_runner build

cd ../../app
flutter pub get
```

### 📱 Running with Android Studio

#### **Option 1: Android Studio IDE (Recommended)**

1. **Open Android Studio**
2. **Open project:**
   ```bash
   # Open Android Studio, then File → Open → Select habit_level_up/app folder
   # OR launch directly from command line:
   open -a "Android Studio" app/
   ```
3. **Wait for indexing** and Gradle sync to complete
4. **Setup Android Emulator:**
   ```bash
   # From Terminal or Android Studio Terminal:
   fvm flutter emulators                    # List available emulators
   fvm flutter emulators --launch Pixel_8_API_34   # Launch emulator
   ```
   - Or use **Tools → AVD Manager** in Android Studio
   - Wait for emulator to fully boot and show home screen
5. **Run the App:**
   ```bash
   # From Terminal:
   cd app
   fvm flutter run
   ```
   - Or in Android Studio: Select emulator from dropdown → Click green ▶️ **Run** button
   - Keyboard shortcut: `Shift + F10` (Windows/Linux) / `⌘ + R` (Mac)

#### **Option 2: Command Line with Android Studio Emulator**

1. **Start Android Studio** (to ensure emulator tools are available)

2. **Launch emulator:**
   ```bash
   # List available emulators
   fvm flutter emulators
   
   # run
   fvm flutter emulators --launch Pixel_8_API_34


   cd app
   fvm flutter run


#### **Option 3: Physical Android Device**

1. **Enable Developer Mode:**
   - Settings → About phone → Tap "Build number" 7 times
   - Settings → Developer options → Enable "USB debugging"

2. **Connect via USB and run:**
   ```bash
   # Verify device is connected
   fvm flutter devices
   
   # Run on connected device
   cd app
   fvm flutter run
   ```

### 🛠️ Development Workflow

#### **Daily Commands**
```bash
# Run in debug mode with hot reload
cd app && fvm flutter run

# Hot reload: press 'r' in terminal
# Hot restart: press 'R' in terminal
# Quit: press 'q' in terminal

# Automated tooling
fvm dart run melos run test        # Run all tests
fvm dart run melos run format      # Format code
fvm dart run melos run analyze     # Static analysis
```

#### **After Domain/Data Changes**
```bash
# Regenerate freezed/json code
cd packages/domain && fvm dart run build_runner build --delete-conflicting-outputs
cd packages/data_local && fvm dart run build_runner build --delete-conflicting-outputs
```

## 🎯 Current MVP Features

**✅ Implemented:**
- Add basic habits with name validation
- Check off daily completions
- Track streaks with 🔥 badges
- ✔ **Routines/Bundles (v0.1)** - Group habits into completion routines
- Persistent local storage (Isar)
- Reactive UI with loading states
- Clean architecture separation

**🔒 Future-Ready:**
- Timed habits (track duration)
- Score-based habits (target points)  
- Cloud sync across devices
- XP system and gamification
- Push notifications

## 🧪 Testing

#### **System Tests (MVP Checklist)**
```bash
cd app
fvm flutter test integration_test/habit_flow_test.dart
```

**Test scenarios:**
1. ✅ Add "Drink water" → List shows one unticked habit
2. ✅ Tap checkbox → Shows completed ✓, streak = 1
3. ✅ Force-quit app → Relaunch → Still completed

#### **Unit Tests**
```bash
fvm dart run melos run test:unit    # Pure Dart packages
fvm dart run melos run test         # All packages
```

## 🔧 Troubleshooting

#### **Build Issues**
```bash
# Clean and rebuild
fvm flutter clean
fvm dart run melos bootstrap
fvm dart run build_runner build --delete-conflicting-outputs
```

#### **Emulator Not Showing**
- Open Android Studio → Tools → AVD Manager
- Ensure emulator is running and visible on screen
- Check connection: `adb devices`
- Try restarting emulator

#### **Path/Version Issues**
```bash
# Verify Flutter setup
fvm flutter doctor -v
which flutter

# Use FVM consistently
fvm flutter run
```

#### **Database/Isar Issues**
```bash
# Clear app data and reinstall
flutter clean
# Uninstall from emulator/device
# Run again to reinstall fresh
```

## 📁 Key Files

**Entry Points:**
- `app/lib/main.dart` - App entry point
- `app/lib/presentation/pages/habits_page.dart` - Main UI

**Domain (Business Logic):**
- `packages/domain/lib/src/entities/habit.dart` - Sealed habit hierarchy
- `packages/domain/lib/src/use_cases/` - Business operations

**Data Persistence:**
- `packages/data_local/lib/src/repositories/isar_habit_repository.dart`
- `packages/data_local/lib/src/models/habit_model.dart`

**UI Components:**
- `app/lib/presentation/widgets/habit_tile.dart`
- `app/lib/presentation/widgets/add_habit_bottom_sheet.dart`

## 🚀 Future Extensibility

**Adding New Habit Variants:**
1. Uncomment `Habit.timed()` in domain layer
2. Add timer UI in `HabitTile` switch statement  
3. Isar automatically handles polymorphic storage
4. Use cases remain unchanged (future-proof!)

**Architecture Benefits:**
- **Sealed classes** ensure compiler catches missing cases
- **Clean separation** allows independent testing
- **Dependency injection** through Riverpod providers
- **Melos workspace** manages multi-package complexity

## 🤝 Contributing

1. **Follow clean architecture** - Domain never imports Flutter
2. **Use sealed classes** for type safety
3. **Write tests** for new features (aim for 90% coverage)
4. **Format code** before commits: `melos run format`
5. **Keep variants future-ready** but locked until needed

## 📄 License

dont steal my code
---

**Built with ❤️ using Flutter's latest best practices and professional architecture patterns.**
