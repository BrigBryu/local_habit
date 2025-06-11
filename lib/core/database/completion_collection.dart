import 'package:isar/isar.dart';

part 'completion_collection.g.dart';

@Collection()
class CompletionCollection {
  Id isarId = Isar.autoIncrement;
  
  late String id;
  late String habitId;
  late String userId;
  late DateTime completedAt;
  int xpAwarded = 0;
  int completionCount = 1; // For multiple completions in one record
  String? notes;

  CompletionCollection();

  factory CompletionCollection.fromHabitCompletion({
    required String habitId,
    required String userId,
    required DateTime completedAt,
    int xpAwarded = 0,
    int completionCount = 1,
    String? notes,
  }) {
    final id = '${habitId}_${completedAt.millisecondsSinceEpoch}';
    return CompletionCollection()
      ..id = id
      ..habitId = habitId
      ..userId = userId
      ..completedAt = completedAt
      ..xpAwarded = xpAwarded
      ..completionCount = completionCount
      ..notes = notes;
  }
}

// TODO: Add proper indexes when needed