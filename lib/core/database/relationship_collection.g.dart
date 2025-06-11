// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRelationshipCollectionCollection on Isar {
  IsarCollection<RelationshipCollection> get relationshipCollections =>
      this.collection();
}

const RelationshipCollectionSchema = CollectionSchema(
  name: r'RelationshipCollection',
  id: -8356743513975113694,
  properties: {
    r'acceptedAt': PropertySchema(
      id: 0,
      name: r'acceptedAt',
      type: IsarType.dateTime,
    ),
    r'canCreateSharedHabits': PropertySchema(
      id: 1,
      name: r'canCreateSharedHabits',
      type: IsarType.bool,
    ),
    r'canViewHabits': PropertySchema(
      id: 2,
      name: r'canViewHabits',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'endedAt': PropertySchema(
      id: 4,
      name: r'endedAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'nickname': PropertySchema(
      id: 6,
      name: r'nickname',
      type: IsarType.string,
    ),
    r'partnerId': PropertySchema(
      id: 7,
      name: r'partnerId',
      type: IsarType.string,
    ),
    r'receiveNotifications': PropertySchema(
      id: 8,
      name: r'receiveNotifications',
      type: IsarType.bool,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
      enumMap: _RelationshipCollectionstatusEnumValueMap,
    ),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
      enumMap: _RelationshipCollectiontypeEnumValueMap,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _relationshipCollectionEstimateSize,
  serialize: _relationshipCollectionSerialize,
  deserialize: _relationshipCollectionDeserialize,
  deserializeProp: _relationshipCollectionDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _relationshipCollectionGetId,
  getLinks: _relationshipCollectionGetLinks,
  attach: _relationshipCollectionAttach,
  version: '3.1.0+1',
);

int _relationshipCollectionEstimateSize(
  RelationshipCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.nickname;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.partnerId.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _relationshipCollectionSerialize(
  RelationshipCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.acceptedAt);
  writer.writeBool(offsets[1], object.canCreateSharedHabits);
  writer.writeBool(offsets[2], object.canViewHabits);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.endedAt);
  writer.writeString(offsets[5], object.id);
  writer.writeString(offsets[6], object.nickname);
  writer.writeString(offsets[7], object.partnerId);
  writer.writeBool(offsets[8], object.receiveNotifications);
  writer.writeString(offsets[9], object.status.name);
  writer.writeString(offsets[10], object.type.name);
  writer.writeString(offsets[11], object.userId);
}

RelationshipCollection _relationshipCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RelationshipCollection();
  object.acceptedAt = reader.readDateTimeOrNull(offsets[0]);
  object.canCreateSharedHabits = reader.readBool(offsets[1]);
  object.canViewHabits = reader.readBool(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.endedAt = reader.readDateTimeOrNull(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.isarId = id;
  object.nickname = reader.readStringOrNull(offsets[6]);
  object.partnerId = reader.readString(offsets[7]);
  object.receiveNotifications = reader.readBool(offsets[8]);
  object.status = _RelationshipCollectionstatusValueEnumMap[
          reader.readStringOrNull(offsets[9])] ??
      RelationshipStatus.pending;
  object.type = _RelationshipCollectiontypeValueEnumMap[
          reader.readStringOrNull(offsets[10])] ??
      RelationshipType.partner;
  object.userId = reader.readString(offsets[11]);
  return object;
}

P _relationshipCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (_RelationshipCollectionstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RelationshipStatus.pending) as P;
    case 10:
      return (_RelationshipCollectiontypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RelationshipType.partner) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RelationshipCollectionstatusEnumValueMap = {
  r'pending': r'pending',
  r'accepted': r'accepted',
  r'blocked': r'blocked',
  r'ended': r'ended',
};
const _RelationshipCollectionstatusValueEnumMap = {
  r'pending': RelationshipStatus.pending,
  r'accepted': RelationshipStatus.accepted,
  r'blocked': RelationshipStatus.blocked,
  r'ended': RelationshipStatus.ended,
};
const _RelationshipCollectiontypeEnumValueMap = {
  r'partner': r'partner',
  r'friend': r'friend',
  r'coach': r'coach',
};
const _RelationshipCollectiontypeValueEnumMap = {
  r'partner': RelationshipType.partner,
  r'friend': RelationshipType.friend,
  r'coach': RelationshipType.coach,
};

Id _relationshipCollectionGetId(RelationshipCollection object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _relationshipCollectionGetLinks(
    RelationshipCollection object) {
  return [];
}

void _relationshipCollectionAttach(
    IsarCollection<dynamic> col, Id id, RelationshipCollection object) {
  object.isarId = id;
}

extension RelationshipCollectionQueryWhereSort
    on QueryBuilder<RelationshipCollection, RelationshipCollection, QWhere> {
  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RelationshipCollectionQueryWhere on QueryBuilder<
    RelationshipCollection, RelationshipCollection, QWhereClause> {
  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RelationshipCollectionQueryFilter on QueryBuilder<
    RelationshipCollection, RelationshipCollection, QFilterCondition> {
  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> acceptedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'acceptedAt',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> acceptedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'acceptedAt',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> acceptedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acceptedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> acceptedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acceptedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> acceptedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acceptedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> acceptedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acceptedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> canCreateSharedHabitsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canCreateSharedHabits',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> canViewHabitsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canViewHabits',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> endedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endedAt',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> endedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endedAt',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> endedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> endedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> endedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> endedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nickname',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nickname',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nickname',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      nicknameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      nicknameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nickname',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickname',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> nicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nickname',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partnerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partnerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partnerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partnerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partnerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      partnerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partnerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      partnerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partnerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerId',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> partnerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partnerId',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> receiveNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiveNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusEqualTo(
    RelationshipStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusGreaterThan(
    RelationshipStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusLessThan(
    RelationshipStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusBetween(
    RelationshipStatus lower,
    RelationshipStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeEqualTo(
    RelationshipType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeGreaterThan(
    RelationshipType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeLessThan(
    RelationshipType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeBetween(
    RelationshipType lower,
    RelationshipType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension RelationshipCollectionQueryObject on QueryBuilder<
    RelationshipCollection, RelationshipCollection, QFilterCondition> {}

extension RelationshipCollectionQueryLinks on QueryBuilder<
    RelationshipCollection, RelationshipCollection, QFilterCondition> {}

extension RelationshipCollectionQuerySortBy
    on QueryBuilder<RelationshipCollection, RelationshipCollection, QSortBy> {
  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByAcceptedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByAcceptedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByCanCreateSharedHabits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canCreateSharedHabits', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByCanCreateSharedHabitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canCreateSharedHabits', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByCanViewHabits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canViewHabits', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByCanViewHabitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canViewHabits', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByPartnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByReceiveNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveNotifications', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByReceiveNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveNotifications', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RelationshipCollectionQuerySortThenBy on QueryBuilder<
    RelationshipCollection, RelationshipCollection, QSortThenBy> {
  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByAcceptedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByAcceptedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acceptedAt', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByCanCreateSharedHabits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canCreateSharedHabits', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByCanCreateSharedHabitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canCreateSharedHabits', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByCanViewHabits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canViewHabits', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByCanViewHabitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canViewHabits', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByPartnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByReceiveNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveNotifications', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByReceiveNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveNotifications', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RelationshipCollectionQueryWhereDistinct
    on QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct> {
  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByAcceptedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acceptedAt');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByCanCreateSharedHabits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canCreateSharedHabits');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByCanViewHabits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canViewHabits');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endedAt');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByNickname({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nickname', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByPartnerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partnerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByReceiveNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiveNotifications');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipCollection, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension RelationshipCollectionQueryProperty on QueryBuilder<
    RelationshipCollection, RelationshipCollection, QQueryProperty> {
  QueryBuilder<RelationshipCollection, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<RelationshipCollection, DateTime?, QQueryOperations>
      acceptedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acceptedAt');
    });
  }

  QueryBuilder<RelationshipCollection, bool, QQueryOperations>
      canCreateSharedHabitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canCreateSharedHabits');
    });
  }

  QueryBuilder<RelationshipCollection, bool, QQueryOperations>
      canViewHabitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canViewHabits');
    });
  }

  QueryBuilder<RelationshipCollection, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RelationshipCollection, DateTime?, QQueryOperations>
      endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endedAt');
    });
  }

  QueryBuilder<RelationshipCollection, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RelationshipCollection, String?, QQueryOperations>
      nicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nickname');
    });
  }

  QueryBuilder<RelationshipCollection, String, QQueryOperations>
      partnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partnerId');
    });
  }

  QueryBuilder<RelationshipCollection, bool, QQueryOperations>
      receiveNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiveNotifications');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<RelationshipCollection, RelationshipType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<RelationshipCollection, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
