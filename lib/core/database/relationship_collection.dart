import 'package:isar/isar.dart';

part 'relationship_collection.g.dart';

enum RelationshipType {
  partner,
  friend,
  coach,
  // TODO: Add more relationship types for future features
}

enum RelationshipStatus {
  pending,
  accepted,
  blocked,
  ended,
}

@Collection()
class RelationshipCollection {
  Id isarId = Isar.autoIncrement;
  
  late String id;
  late String userId; // The user who owns this relationship record
  late String partnerId; // The other user in the relationship
  
  @Enumerated(EnumType.name)
  late RelationshipType type;
  
  @Enumerated(EnumType.name)
  late RelationshipStatus status;
  
  late DateTime createdAt;
  DateTime? acceptedAt;
  DateTime? endedAt;
  String? nickname; // Optional display name for the partner
  bool canViewHabits = false;
  bool canCreateSharedHabits = false;
  bool receiveNotifications = false;

  RelationshipCollection();

  factory RelationshipCollection.createPartnership({
    required String userId,
    required String partnerId,
    String? nickname,
    bool canViewHabits = true,
    bool canCreateSharedHabits = false,
    bool receiveNotifications = true,
  }) {
    final id = '${userId}_${partnerId}_${DateTime.now().millisecondsSinceEpoch}';
    return RelationshipCollection()
      ..id = id
      ..userId = userId
      ..partnerId = partnerId
      ..type = RelationshipType.partner
      ..status = RelationshipStatus.pending
      ..createdAt = DateTime.now()
      ..nickname = nickname
      ..canViewHabits = canViewHabits
      ..canCreateSharedHabits = canCreateSharedHabits
      ..receiveNotifications = receiveNotifications;
  }
}

// TODO: Add proper indexes when needed