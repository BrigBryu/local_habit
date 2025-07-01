// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLedgerCollectionCollection on Isar {
  IsarCollection<LedgerCollection> get ledgerCollections => this.collection();
}

const LedgerCollectionSchema = CollectionSchema(
  name: r'LedgerCollection',
  id: 4070395121189729215,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'isCredit': PropertySchema(
      id: 2,
      name: r'isCredit',
      type: IsarType.bool,
    ),
    r'isDebit': PropertySchema(
      id: 3,
      name: r'isDebit',
      type: IsarType.bool,
    ),
    r'isShopPurchase': PropertySchema(
      id: 4,
      name: r'isShopPurchase',
      type: IsarType.bool,
    ),
    r'isStreakBreak': PropertySchema(
      id: 5,
      name: r'isStreakBreak',
      type: IsarType.bool,
    ),
    r'isStreakReward': PropertySchema(
      id: 6,
      name: r'isStreakReward',
      type: IsarType.bool,
    ),
    r'reason': PropertySchema(
      id: 7,
      name: r'reason',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 9,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _ledgerCollectionEstimateSize,
  serialize: _ledgerCollectionSerialize,
  deserialize: _ledgerCollectionDeserialize,
  deserializeProp: _ledgerCollectionDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ledgerCollectionGetId,
  getLinks: _ledgerCollectionGetLinks,
  attach: _ledgerCollectionAttach,
  version: '3.1.0+1',
);

int _ledgerCollectionEstimateSize(
  LedgerCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _ledgerCollectionSerialize(
  LedgerCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeString(offsets[1], object.id);
  writer.writeBool(offsets[2], object.isCredit);
  writer.writeBool(offsets[3], object.isDebit);
  writer.writeBool(offsets[4], object.isShopPurchase);
  writer.writeBool(offsets[5], object.isStreakBreak);
  writer.writeBool(offsets[6], object.isStreakReward);
  writer.writeString(offsets[7], object.reason);
  writer.writeDateTime(offsets[8], object.timestamp);
  writer.writeString(offsets[9], object.userId);
}

LedgerCollection _ledgerCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LedgerCollection();
  object.amount = reader.readLong(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.isarId = id;
  object.reason = reader.readString(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  object.userId = reader.readString(offsets[9]);
  return object;
}

P _ledgerCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ledgerCollectionGetId(LedgerCollection object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _ledgerCollectionGetLinks(LedgerCollection object) {
  return [];
}

void _ledgerCollectionAttach(
    IsarCollection<dynamic> col, Id id, LedgerCollection object) {
  object.isarId = id;
}

extension LedgerCollectionQueryWhereSort
    on QueryBuilder<LedgerCollection, LedgerCollection, QWhere> {
  QueryBuilder<LedgerCollection, LedgerCollection, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LedgerCollectionQueryWhere
    on QueryBuilder<LedgerCollection, LedgerCollection, QWhereClause> {
  QueryBuilder<LedgerCollection, LedgerCollection, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterWhereClause>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterWhereClause>
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

extension LedgerCollectionQueryFilter
    on QueryBuilder<LedgerCollection, LedgerCollection, QFilterCondition> {
  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      amountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      amountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      amountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      isCreditEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCredit',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      isDebitEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDebit',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      isShopPurchaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isShopPurchase',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      isStreakBreakEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStreakBreak',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      isStreakRewardEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStreakReward',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
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

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension LedgerCollectionQueryObject
    on QueryBuilder<LedgerCollection, LedgerCollection, QFilterCondition> {}

extension LedgerCollectionQueryLinks
    on QueryBuilder<LedgerCollection, LedgerCollection, QFilterCondition> {}

extension LedgerCollectionQuerySortBy
    on QueryBuilder<LedgerCollection, LedgerCollection, QSortBy> {
  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCredit', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsCreditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCredit', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDebit', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDebit', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsShopPurchase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShopPurchase', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsShopPurchaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShopPurchase', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsStreakBreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBreak', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsStreakBreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBreak', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsStreakReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakReward', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByIsStreakRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakReward', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LedgerCollectionQuerySortThenBy
    on QueryBuilder<LedgerCollection, LedgerCollection, QSortThenBy> {
  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCredit', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsCreditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCredit', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDebit', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDebit', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsShopPurchase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShopPurchase', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsShopPurchaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShopPurchase', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsStreakBreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBreak', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsStreakBreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBreak', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsStreakReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakReward', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsStreakRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakReward', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LedgerCollectionQueryWhereDistinct
    on QueryBuilder<LedgerCollection, LedgerCollection, QDistinct> {
  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByIsCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCredit');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByIsDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDebit');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByIsShopPurchase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isShopPurchase');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByIsStreakBreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStreakBreak');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByIsStreakReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStreakReward');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<LedgerCollection, LedgerCollection, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension LedgerCollectionQueryProperty
    on QueryBuilder<LedgerCollection, LedgerCollection, QQueryProperty> {
  QueryBuilder<LedgerCollection, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<LedgerCollection, int, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<LedgerCollection, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LedgerCollection, bool, QQueryOperations> isCreditProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCredit');
    });
  }

  QueryBuilder<LedgerCollection, bool, QQueryOperations> isDebitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDebit');
    });
  }

  QueryBuilder<LedgerCollection, bool, QQueryOperations>
      isShopPurchaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isShopPurchase');
    });
  }

  QueryBuilder<LedgerCollection, bool, QQueryOperations>
      isStreakBreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStreakBreak');
    });
  }

  QueryBuilder<LedgerCollection, bool, QQueryOperations>
      isStreakRewardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStreakReward');
    });
  }

  QueryBuilder<LedgerCollection, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<LedgerCollection, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<LedgerCollection, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
