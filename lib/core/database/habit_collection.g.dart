// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHabitCollectionCollection on Isar {
  IsarCollection<HabitCollection> get habitCollections => this.collection();
}

const HabitCollectionSchema = CollectionSchema(
  name: r'HabitCollection',
  id: -9048742641665595188,
  properties: {
    r'availableDays': PropertySchema(
      id: 0,
      name: r'availableDays',
      type: IsarType.longList,
    ),
    r'avoidanceSuccessToday': PropertySchema(
      id: 1,
      name: r'avoidanceSuccessToday',
      type: IsarType.bool,
    ),
    r'bundleChildIds': PropertySchema(
      id: 2,
      name: r'bundleChildIds',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentChildIndex': PropertySchema(
      id: 4,
      name: r'currentChildIndex',
      type: IsarType.long,
    ),
    r'currentStreak': PropertySchema(
      id: 5,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'dailyCompletionCount': PropertySchema(
      id: 6,
      name: r'dailyCompletionCount',
      type: IsarType.long,
    ),
    r'dailyFailureCount': PropertySchema(
      id: 7,
      name: r'dailyFailureCount',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 8,
      name: r'description',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 9,
      name: r'id',
      type: IsarType.string,
    ),
    r'intervalDays': PropertySchema(
      id: 10,
      name: r'intervalDays',
      type: IsarType.long,
    ),
    r'lastAlarmTriggered': PropertySchema(
      id: 11,
      name: r'lastAlarmTriggered',
      type: IsarType.dateTime,
    ),
    r'lastCompleted': PropertySchema(
      id: 12,
      name: r'lastCompleted',
      type: IsarType.dateTime,
    ),
    r'lastCompletionCountReset': PropertySchema(
      id: 13,
      name: r'lastCompletionCountReset',
      type: IsarType.dateTime,
    ),
    r'lastCompletionDate': PropertySchema(
      id: 14,
      name: r'lastCompletionDate',
      type: IsarType.dateTime,
    ),
    r'lastFailureCountReset': PropertySchema(
      id: 15,
      name: r'lastFailureCountReset',
      type: IsarType.dateTime,
    ),
    r'lastSessionStarted': PropertySchema(
      id: 16,
      name: r'lastSessionStarted',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 17,
      name: r'name',
      type: IsarType.string,
    ),
    r'parentBundleId': PropertySchema(
      id: 18,
      name: r'parentBundleId',
      type: IsarType.string,
    ),
    r'parentStackId': PropertySchema(
      id: 19,
      name: r'parentStackId',
      type: IsarType.string,
    ),
    r'sessionCompletedToday': PropertySchema(
      id: 20,
      name: r'sessionCompletedToday',
      type: IsarType.bool,
    ),
    r'sessionStartTime': PropertySchema(
      id: 21,
      name: r'sessionStartTime',
      type: IsarType.dateTime,
    ),
    r'stackChildIds': PropertySchema(
      id: 22,
      name: r'stackChildIds',
      type: IsarType.stringList,
    ),
    r'stackedOnHabitId': PropertySchema(
      id: 23,
      name: r'stackedOnHabitId',
      type: IsarType.string,
    ),
    r'timeoutMinutes': PropertySchema(
      id: 24,
      name: r'timeoutMinutes',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 25,
      name: r'type',
      type: IsarType.string,
      enumMap: _HabitCollectiontypeEnumValueMap,
    ),
    r'userId': PropertySchema(
      id: 26,
      name: r'userId',
      type: IsarType.string,
    ),
    r'weekdayMask': PropertySchema(
      id: 27,
      name: r'weekdayMask',
      type: IsarType.long,
    )
  },
  estimateSize: _habitCollectionEstimateSize,
  serialize: _habitCollectionSerialize,
  deserialize: _habitCollectionDeserialize,
  deserializeProp: _habitCollectionDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _habitCollectionGetId,
  getLinks: _habitCollectionGetLinks,
  attach: _habitCollectionAttach,
  version: '3.1.0+1',
);

int _habitCollectionEstimateSize(
  HabitCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.availableDays;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final list = object.bundleChildIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.parentBundleId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parentStackId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.stackChildIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.stackedOnHabitId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _habitCollectionSerialize(
  HabitCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.availableDays);
  writer.writeBool(offsets[1], object.avoidanceSuccessToday);
  writer.writeStringList(offsets[2], object.bundleChildIds);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.currentChildIndex);
  writer.writeLong(offsets[5], object.currentStreak);
  writer.writeLong(offsets[6], object.dailyCompletionCount);
  writer.writeLong(offsets[7], object.dailyFailureCount);
  writer.writeString(offsets[8], object.description);
  writer.writeString(offsets[9], object.id);
  writer.writeLong(offsets[10], object.intervalDays);
  writer.writeDateTime(offsets[11], object.lastAlarmTriggered);
  writer.writeDateTime(offsets[12], object.lastCompleted);
  writer.writeDateTime(offsets[13], object.lastCompletionCountReset);
  writer.writeDateTime(offsets[14], object.lastCompletionDate);
  writer.writeDateTime(offsets[15], object.lastFailureCountReset);
  writer.writeDateTime(offsets[16], object.lastSessionStarted);
  writer.writeString(offsets[17], object.name);
  writer.writeString(offsets[18], object.parentBundleId);
  writer.writeString(offsets[19], object.parentStackId);
  writer.writeBool(offsets[20], object.sessionCompletedToday);
  writer.writeDateTime(offsets[21], object.sessionStartTime);
  writer.writeStringList(offsets[22], object.stackChildIds);
  writer.writeString(offsets[23], object.stackedOnHabitId);
  writer.writeLong(offsets[24], object.timeoutMinutes);
  writer.writeString(offsets[25], object.type.name);
  writer.writeString(offsets[26], object.userId);
  writer.writeLong(offsets[27], object.weekdayMask);
}

HabitCollection _habitCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HabitCollection();
  object.availableDays = reader.readLongList(offsets[0]);
  object.avoidanceSuccessToday = reader.readBool(offsets[1]);
  object.bundleChildIds = reader.readStringList(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.currentChildIndex = reader.readLong(offsets[4]);
  object.currentStreak = reader.readLong(offsets[5]);
  object.dailyCompletionCount = reader.readLong(offsets[6]);
  object.dailyFailureCount = reader.readLong(offsets[7]);
  object.description = reader.readString(offsets[8]);
  object.id = reader.readString(offsets[9]);
  object.intervalDays = reader.readLongOrNull(offsets[10]);
  object.isarId = id;
  object.lastAlarmTriggered = reader.readDateTimeOrNull(offsets[11]);
  object.lastCompleted = reader.readDateTimeOrNull(offsets[12]);
  object.lastCompletionCountReset = reader.readDateTimeOrNull(offsets[13]);
  object.lastCompletionDate = reader.readDateTimeOrNull(offsets[14]);
  object.lastFailureCountReset = reader.readDateTimeOrNull(offsets[15]);
  object.lastSessionStarted = reader.readDateTimeOrNull(offsets[16]);
  object.name = reader.readString(offsets[17]);
  object.parentBundleId = reader.readStringOrNull(offsets[18]);
  object.parentStackId = reader.readStringOrNull(offsets[19]);
  object.sessionCompletedToday = reader.readBool(offsets[20]);
  object.sessionStartTime = reader.readDateTimeOrNull(offsets[21]);
  object.stackChildIds = reader.readStringList(offsets[22]);
  object.stackedOnHabitId = reader.readStringOrNull(offsets[23]);
  object.timeoutMinutes = reader.readLongOrNull(offsets[24]);
  object.type =
      _HabitCollectiontypeValueEnumMap[reader.readStringOrNull(offsets[25])] ??
          HabitType.basic;
  object.userId = reader.readString(offsets[26]);
  object.weekdayMask = reader.readLongOrNull(offsets[27]);
  return object;
}

P _habitCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readStringList(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    case 25:
      return (_HabitCollectiontypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          HabitType.basic) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _HabitCollectiontypeEnumValueMap = {
  r'basic': r'basic',
  r'avoidance': r'avoidance',
  r'stack': r'stack',
  r'bundle': r'bundle',
  r'interval': r'interval',
  r'weekly': r'weekly',
};
const _HabitCollectiontypeValueEnumMap = {
  r'basic': HabitType.basic,
  r'avoidance': HabitType.avoidance,
  r'stack': HabitType.stack,
  r'bundle': HabitType.bundle,
  r'interval': HabitType.interval,
  r'weekly': HabitType.weekly,
};

Id _habitCollectionGetId(HabitCollection object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _habitCollectionGetLinks(HabitCollection object) {
  return [];
}

void _habitCollectionAttach(
    IsarCollection<dynamic> col, Id id, HabitCollection object) {
  object.isarId = id;
}

extension HabitCollectionQueryWhereSort
    on QueryBuilder<HabitCollection, HabitCollection, QWhere> {
  QueryBuilder<HabitCollection, HabitCollection, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HabitCollectionQueryWhere
    on QueryBuilder<HabitCollection, HabitCollection, QWhereClause> {
  QueryBuilder<HabitCollection, HabitCollection, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterWhereClause>
      isarIdBetween(
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

extension HabitCollectionQueryFilter
    on QueryBuilder<HabitCollection, HabitCollection, QFilterCondition> {
  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'availableDays',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'availableDays',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availableDays',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availableDays',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availableDays',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availableDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'availableDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'availableDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'availableDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'availableDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'availableDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      availableDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'availableDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      avoidanceSuccessTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avoidanceSuccessToday',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bundleChildIds',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bundleChildIds',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bundleChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bundleChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bundleChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bundleChildIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bundleChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bundleChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bundleChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bundleChildIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bundleChildIds',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bundleChildIds',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bundleChildIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bundleChildIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bundleChildIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bundleChildIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bundleChildIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      bundleChildIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bundleChildIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentChildIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentChildIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentChildIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentChildIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentChildIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentChildIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentChildIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentChildIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyCompletionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyCompletionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyCompletionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyCompletionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyCompletionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyCompletionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyCompletionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyCompletionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyFailureCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyFailureCount',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyFailureCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyFailureCount',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyFailureCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyFailureCount',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      dailyFailureCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyFailureCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idEqualTo(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idStartsWith(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idEndsWith(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      intervalDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intervalDays',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      intervalDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intervalDays',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      intervalDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      intervalDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      intervalDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      intervalDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      isarIdGreaterThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      isarIdLessThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      isarIdBetween(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastAlarmTriggeredIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAlarmTriggered',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastAlarmTriggeredIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAlarmTriggered',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastAlarmTriggeredEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAlarmTriggered',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastAlarmTriggeredGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAlarmTriggered',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastAlarmTriggeredLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAlarmTriggered',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastAlarmTriggeredBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAlarmTriggered',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCompleted',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCompleted',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionCountResetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCompletionCountReset',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionCountResetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCompletionCountReset',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionCountResetEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCompletionCountReset',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionCountResetGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCompletionCountReset',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionCountResetLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCompletionCountReset',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionCountResetBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCompletionCountReset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCompletionDate',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCompletionDate',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastCompletionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCompletionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastFailureCountResetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastFailureCountReset',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastFailureCountResetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastFailureCountReset',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastFailureCountResetEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFailureCountReset',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastFailureCountResetGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFailureCountReset',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastFailureCountResetLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFailureCountReset',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastFailureCountResetBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFailureCountReset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastSessionStartedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSessionStarted',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastSessionStartedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSessionStarted',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastSessionStartedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSessionStarted',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastSessionStartedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSessionStarted',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastSessionStartedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSessionStarted',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      lastSessionStartedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSessionStarted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentBundleId',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentBundleId',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentBundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentBundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentBundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentBundleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentBundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentBundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentBundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentBundleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentBundleId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentBundleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentBundleId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentStackId',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentStackId',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentStackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentStackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentStackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentStackId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentStackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentStackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentStackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentStackId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentStackId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      parentStackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentStackId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionCompletedTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionCompletedToday',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionStartTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sessionStartTime',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionStartTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sessionStartTime',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionStartTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionStartTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionStartTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      sessionStartTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionStartTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stackChildIds',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stackChildIds',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stackChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stackChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stackChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stackChildIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stackChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stackChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stackChildIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stackChildIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stackChildIds',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stackChildIds',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stackChildIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stackChildIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stackChildIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stackChildIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stackChildIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackChildIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stackChildIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stackedOnHabitId',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stackedOnHabitId',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stackedOnHabitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stackedOnHabitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stackedOnHabitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stackedOnHabitId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stackedOnHabitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stackedOnHabitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stackedOnHabitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stackedOnHabitId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stackedOnHabitId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      stackedOnHabitIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stackedOnHabitId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      timeoutMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timeoutMinutes',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      timeoutMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timeoutMinutes',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      timeoutMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      timeoutMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      timeoutMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      timeoutMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeoutMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeEqualTo(
    HabitType value, {
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeGreaterThan(
    HabitType value, {
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeLessThan(
    HabitType value, {
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeBetween(
    HabitType lower,
    HabitType upper, {
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeStartsWith(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeEndsWith(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdEqualTo(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdGreaterThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdLessThan(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdBetween(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdStartsWith(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdEndsWith(
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

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      weekdayMaskIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weekdayMask',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      weekdayMaskIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weekdayMask',
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      weekdayMaskEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekdayMask',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      weekdayMaskGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekdayMask',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      weekdayMaskLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekdayMask',
        value: value,
      ));
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterFilterCondition>
      weekdayMaskBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekdayMask',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HabitCollectionQueryObject
    on QueryBuilder<HabitCollection, HabitCollection, QFilterCondition> {}

extension HabitCollectionQueryLinks
    on QueryBuilder<HabitCollection, HabitCollection, QFilterCondition> {}

extension HabitCollectionQuerySortBy
    on QueryBuilder<HabitCollection, HabitCollection, QSortBy> {
  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByAvoidanceSuccessToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avoidanceSuccessToday', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByAvoidanceSuccessTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avoidanceSuccessToday', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByCurrentChildIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentChildIndex', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByCurrentChildIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentChildIndex', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByDailyCompletionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCompletionCount', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByDailyCompletionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCompletionCount', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByDailyFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFailureCount', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByDailyFailureCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFailureCount', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastAlarmTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlarmTriggered', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastAlarmTriggeredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlarmTriggered', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompleted', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompleted', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastCompletionCountReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionCountReset', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastCompletionCountResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionCountReset', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastFailureCountReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureCountReset', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastFailureCountResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureCountReset', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastSessionStarted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSessionStarted', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByLastSessionStartedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSessionStarted', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByParentBundleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentBundleId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByParentBundleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentBundleId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByParentStackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentStackId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByParentStackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentStackId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortBySessionCompletedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCompletedToday', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortBySessionCompletedTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCompletedToday', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortBySessionStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStartTime', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortBySessionStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStartTime', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByStackedOnHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stackedOnHabitId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByStackedOnHabitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stackedOnHabitId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByTimeoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutMinutes', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByWeekdayMask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekdayMask', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      sortByWeekdayMaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekdayMask', Sort.desc);
    });
  }
}

extension HabitCollectionQuerySortThenBy
    on QueryBuilder<HabitCollection, HabitCollection, QSortThenBy> {
  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByAvoidanceSuccessToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avoidanceSuccessToday', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByAvoidanceSuccessTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avoidanceSuccessToday', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByCurrentChildIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentChildIndex', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByCurrentChildIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentChildIndex', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByDailyCompletionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCompletionCount', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByDailyCompletionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCompletionCount', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByDailyFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFailureCount', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByDailyFailureCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFailureCount', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastAlarmTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlarmTriggered', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastAlarmTriggeredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAlarmTriggered', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompleted', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompleted', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastCompletionCountReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionCountReset', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastCompletionCountResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionCountReset', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastFailureCountReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureCountReset', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastFailureCountResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureCountReset', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastSessionStarted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSessionStarted', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByLastSessionStartedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSessionStarted', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByParentBundleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentBundleId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByParentBundleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentBundleId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByParentStackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentStackId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByParentStackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentStackId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenBySessionCompletedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCompletedToday', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenBySessionCompletedTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCompletedToday', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenBySessionStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStartTime', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenBySessionStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStartTime', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByStackedOnHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stackedOnHabitId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByStackedOnHabitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stackedOnHabitId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByTimeoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutMinutes', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByWeekdayMask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekdayMask', Sort.asc);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QAfterSortBy>
      thenByWeekdayMaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekdayMask', Sort.desc);
    });
  }
}

extension HabitCollectionQueryWhereDistinct
    on QueryBuilder<HabitCollection, HabitCollection, QDistinct> {
  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByAvailableDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableDays');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByAvoidanceSuccessToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avoidanceSuccessToday');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByBundleChildIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bundleChildIds');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByCurrentChildIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentChildIndex');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByDailyCompletionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCompletionCount');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByDailyFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyFailureCount');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalDays');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByLastAlarmTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAlarmTriggered');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByLastCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCompleted');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByLastCompletionCountReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCompletionCountReset');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByLastCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCompletionDate');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByLastFailureCountReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFailureCountReset');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByLastSessionStarted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSessionStarted');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByParentBundleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentBundleId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByParentStackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentStackId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctBySessionCompletedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionCompletedToday');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctBySessionStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionStartTime');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByStackChildIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stackChildIds');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByStackedOnHabitId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stackedOnHabitId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeoutMinutes');
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HabitCollection, HabitCollection, QDistinct>
      distinctByWeekdayMask() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekdayMask');
    });
  }
}

extension HabitCollectionQueryProperty
    on QueryBuilder<HabitCollection, HabitCollection, QQueryProperty> {
  QueryBuilder<HabitCollection, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<HabitCollection, List<int>?, QQueryOperations>
      availableDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableDays');
    });
  }

  QueryBuilder<HabitCollection, bool, QQueryOperations>
      avoidanceSuccessTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avoidanceSuccessToday');
    });
  }

  QueryBuilder<HabitCollection, List<String>?, QQueryOperations>
      bundleChildIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bundleChildIds');
    });
  }

  QueryBuilder<HabitCollection, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<HabitCollection, int, QQueryOperations>
      currentChildIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentChildIndex');
    });
  }

  QueryBuilder<HabitCollection, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<HabitCollection, int, QQueryOperations>
      dailyCompletionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCompletionCount');
    });
  }

  QueryBuilder<HabitCollection, int, QQueryOperations>
      dailyFailureCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyFailureCount');
    });
  }

  QueryBuilder<HabitCollection, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<HabitCollection, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HabitCollection, int?, QQueryOperations> intervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalDays');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      lastAlarmTriggeredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAlarmTriggered');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      lastCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCompleted');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      lastCompletionCountResetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCompletionCountReset');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      lastCompletionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCompletionDate');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      lastFailureCountResetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFailureCountReset');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      lastSessionStartedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSessionStarted');
    });
  }

  QueryBuilder<HabitCollection, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<HabitCollection, String?, QQueryOperations>
      parentBundleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentBundleId');
    });
  }

  QueryBuilder<HabitCollection, String?, QQueryOperations>
      parentStackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentStackId');
    });
  }

  QueryBuilder<HabitCollection, bool, QQueryOperations>
      sessionCompletedTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionCompletedToday');
    });
  }

  QueryBuilder<HabitCollection, DateTime?, QQueryOperations>
      sessionStartTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionStartTime');
    });
  }

  QueryBuilder<HabitCollection, List<String>?, QQueryOperations>
      stackChildIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stackChildIds');
    });
  }

  QueryBuilder<HabitCollection, String?, QQueryOperations>
      stackedOnHabitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stackedOnHabitId');
    });
  }

  QueryBuilder<HabitCollection, int?, QQueryOperations>
      timeoutMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeoutMinutes');
    });
  }

  QueryBuilder<HabitCollection, HabitType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<HabitCollection, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<HabitCollection, int?, QQueryOperations> weekdayMaskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekdayMask');
    });
  }
}
