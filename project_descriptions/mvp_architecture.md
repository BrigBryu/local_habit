# Habit Level Up - Professional Flutter Architecture

## MVP Feature Checklist ✅

**Core Flow**: "Add a habit → tick it → see that it stuck"

### Architecture Overview

```
habit_level_up/
├─ packages/
│   ├─ domain/           ← Pure Dart: Habit entities, use cases
│   ├─ data_local/       ← Isar persistence with discriminator pattern
│   ├─ data_remote/      ← Future: Firebase/Supabase sync
│   └─ features/         ← Future: Modular features
├─ app/                  ← Flutter UI entry point
└─ melos.yaml           ← Workspace management
```

### Domain Layer (Pure Dart)

**Sealed Habit Hierarchy** - Future-proof polymorphic design:
```dart
@Freezed(unionKey: 'type')
sealed class Habit with _$Habit {
  const factory Habit.basic({...}) = BasicHabit;     // ✅ MVP
  // const factory Habit.timed({...}) = TimedHabit;  // 🔒 Future
  // const factory Habit.score({...}) = ScoreHabit;  // 🔒 Future
}
```

**MVP Use Cases**:
- `AddHabitUseCase(name) → habitId`
- `CompleteHabitUseCase(id, when) → awardedXP`

### Data Layer

**Isar Persistence** with discriminator column:
- Single `habits` table with `type = "basic"`
- JSON `extras` column ready for variant-specific data
- Write-through transactions ensure consistency

### Presentation Layer

**Riverpod State Management**:
- Repository → Use Cases → UI Providers
- Stream-based reactive UI
- Loading states and error handling

**MVP UI Components**:
- ✅ Add Habit FAB → Bottom sheet with name TextField
- ✅ HabitTile: Checkbox + name + streak badge
- ✅ Empty state with helpful messaging

## System Tests Checklist

1. **Add "Drink water"** → List shows one unticked habit ✅
2. **Tap checkbox** → Tile shows completed ✓, streak = 1 ✅  
3. **Force-quit app** → Relaunch → Still completed ✅

## Development Commands

**Setup workspace:**
```bash
cd habit_level_up
dart pub global activate melos
melos bootstrap
```

**Generate code:**
```bash
melos run deps:get
cd packages/domain && dart run build_runner build
cd packages/data_local && dart run build_runner build
```

**Run app:**
```bash
cd app
flutter run -d emulator-5554
```

**Testing:**
```bash
melos run test        # All tests
melos run analyze     # Static analysis
melos run format      # Code formatting
```

## Future Extensibility

**Adding TimedHabit variant:**
1. Uncomment `Habit.timed()` in domain
2. Add timer UI in HabitTile switch statement
3. Isar auto-handles JSON serialization
4. Use cases remain unchanged

**Key Benefits:**
- ✅ Version pinned (FVM + locked pubspec.lock)
- ✅ Domain separated from framework
- ✅ Immutable entities with freezed
- ✅ Local-first with sync queue ready
- ✅ Automated tooling (melos scripts)
- ✅ Sealed class compiler safety
- ✅ Future-proof polymorphic design

## Architecture Principles

**Dependency Flow**: Presentation → Domain ← Data

**Layer Responsibilities**:
- **Domain**: Business logic, entities, use cases (pure Dart)
- **Data Local**: Isar models, repository implementation  
- **Data Remote**: Future cloud sync implementation
- **Presentation**: Riverpod providers, widgets, state management

**Never Import**:
- Domain never imports Flutter/Isar/Firebase
- Data layers never import widgets
- Each layer only knows about domain interfaces