// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncOpCollection on Isar {
  IsarCollection<SyncOp> get syncOps => this.collection();
}

const SyncOpSchema = CollectionSchema(
  name: r'SyncOp',
  id: 3244830614340238567,
  properties: {
    r'attemptCount': PropertySchema(
      id: 0,
      name: r'attemptCount',
      type: IsarType.long,
    ),
    r'completed': PropertySchema(
      id: 1,
      name: r'completed',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'errorMessage': PropertySchema(
      id: 3,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'habitData': PropertySchema(
      id: 4,
      name: r'habitData',
      type: IsarType.string,
    ),
    r'habitId': PropertySchema(
      id: 5,
      name: r'habitId',
      type: IsarType.string,
    ),
    r'lastAttempt': PropertySchema(
      id: 6,
      name: r'lastAttempt',
      type: IsarType.dateTime,
    ),
    r'maxRetries': PropertySchema(
      id: 7,
      name: r'maxRetries',
      type: IsarType.long,
    ),
    r'operationType': PropertySchema(
      id: 8,
      name: r'operationType',
      type: IsarType.string,
    ),
    r'xpAwarded': PropertySchema(
      id: 9,
      name: r'xpAwarded',
      type: IsarType.long,
    )
  },
  estimateSize: _syncOpEstimateSize,
  serialize: _syncOpSerialize,
  deserialize: _syncOpDeserialize,
  deserializeProp: _syncOpDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _syncOpGetId,
  getLinks: _syncOpGetLinks,
  attach: _syncOpAttach,
  version: '3.1.0+1',
);

int _syncOpEstimateSize(
  SyncOp object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.habitData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.habitId.length * 3;
  bytesCount += 3 + object.operationType.length * 3;
  return bytesCount;
}

void _syncOpSerialize(
  SyncOp object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attemptCount);
  writer.writeBool(offsets[1], object.completed);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.errorMessage);
  writer.writeString(offsets[4], object.habitData);
  writer.writeString(offsets[5], object.habitId);
  writer.writeDateTime(offsets[6], object.lastAttempt);
  writer.writeLong(offsets[7], object.maxRetries);
  writer.writeString(offsets[8], object.operationType);
  writer.writeLong(offsets[9], object.xpAwarded);
}

SyncOp _syncOpDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncOp();
  object.attemptCount = reader.readLong(offsets[0]);
  object.completed = reader.readBool(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.errorMessage = reader.readStringOrNull(offsets[3]);
  object.habitData = reader.readStringOrNull(offsets[4]);
  object.habitId = reader.readString(offsets[5]);
  object.id = id;
  object.lastAttempt = reader.readDateTimeOrNull(offsets[6]);
  object.maxRetries = reader.readLong(offsets[7]);
  object.operationType = reader.readString(offsets[8]);
  object.xpAwarded = reader.readLong(offsets[9]);
  return object;
}

P _syncOpDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncOpGetId(SyncOp object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncOpGetLinks(SyncOp object) {
  return [];
}

void _syncOpAttach(IsarCollection<dynamic> col, Id id, SyncOp object) {
  object.id = id;
}

extension SyncOpQueryWhereSort on QueryBuilder<SyncOp, SyncOp, QWhere> {
  QueryBuilder<SyncOp, SyncOp, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncOpQueryWhere on QueryBuilder<SyncOp, SyncOp, QWhereClause> {
  QueryBuilder<SyncOp, SyncOp, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncOpQueryFilter on QueryBuilder<SyncOp, SyncOp, QFilterCondition> {
  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> attemptCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> attemptCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> attemptCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> attemptCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attemptCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> completedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completed',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'habitData',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'habitData',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'habitData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'habitData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'habitData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'habitData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitData',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'habitData',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'habitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'habitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'habitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'habitId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> habitIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'habitId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> lastAttemptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAttempt',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> lastAttemptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAttempt',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> lastAttemptEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> lastAttemptGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> lastAttemptLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> lastAttemptBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAttempt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> maxRetriesEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxRetries',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> maxRetriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxRetries',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> maxRetriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxRetries',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> maxRetriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxRetries',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> operationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationType',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition>
      operationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationType',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> xpAwardedEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpAwarded',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> xpAwardedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpAwarded',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> xpAwardedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpAwarded',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterFilterCondition> xpAwardedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpAwarded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncOpQueryObject on QueryBuilder<SyncOp, SyncOp, QFilterCondition> {}

extension SyncOpQueryLinks on QueryBuilder<SyncOp, SyncOp, QFilterCondition> {}

extension SyncOpQuerySortBy on QueryBuilder<SyncOp, SyncOp, QSortBy> {
  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByHabitData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitData', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByHabitDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitData', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitId', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByHabitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitId', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByLastAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempt', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByLastAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempt', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByMaxRetries() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByMaxRetriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByOperationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByOperationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByXpAwarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAwarded', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> sortByXpAwardedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAwarded', Sort.desc);
    });
  }
}

extension SyncOpQuerySortThenBy on QueryBuilder<SyncOp, SyncOp, QSortThenBy> {
  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByHabitData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitData', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByHabitDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitData', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitId', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByHabitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitId', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByLastAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempt', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByLastAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempt', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByMaxRetries() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByMaxRetriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByOperationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByOperationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.desc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByXpAwarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAwarded', Sort.asc);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QAfterSortBy> thenByXpAwardedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAwarded', Sort.desc);
    });
  }
}

extension SyncOpQueryWhereDistinct on QueryBuilder<SyncOp, SyncOp, QDistinct> {
  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptCount');
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completed');
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByErrorMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByHabitData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByHabitId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByLastAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAttempt');
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByMaxRetries() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxRetries');
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByOperationType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOp, SyncOp, QDistinct> distinctByXpAwarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpAwarded');
    });
  }
}

extension SyncOpQueryProperty on QueryBuilder<SyncOp, SyncOp, QQueryProperty> {
  QueryBuilder<SyncOp, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncOp, int, QQueryOperations> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptCount');
    });
  }

  QueryBuilder<SyncOp, bool, QQueryOperations> completedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completed');
    });
  }

  QueryBuilder<SyncOp, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SyncOp, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<SyncOp, String?, QQueryOperations> habitDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitData');
    });
  }

  QueryBuilder<SyncOp, String, QQueryOperations> habitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitId');
    });
  }

  QueryBuilder<SyncOp, DateTime?, QQueryOperations> lastAttemptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAttempt');
    });
  }

  QueryBuilder<SyncOp, int, QQueryOperations> maxRetriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxRetries');
    });
  }

  QueryBuilder<SyncOp, String, QQueryOperations> operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationType');
    });
  }

  QueryBuilder<SyncOp, int, QQueryOperations> xpAwardedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpAwarded');
    });
  }
}
