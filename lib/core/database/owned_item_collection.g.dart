// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_item_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOwnedItemCollectionCollection on Isar {
  IsarCollection<OwnedItemCollection> get ownedItemCollections =>
      this.collection();
}

const OwnedItemCollectionSchema = CollectionSchema(
  name: r'OwnedItemCollection',
  id: -7204338253414644688,
  properties: {
    r'id': PropertySchema(
      id: 0,
      name: r'id',
      type: IsarType.string,
    ),
    r'isEquipped': PropertySchema(
      id: 1,
      name: r'isEquipped',
      type: IsarType.bool,
    ),
    r'purchasedAt': PropertySchema(
      id: 2,
      name: r'purchasedAt',
      type: IsarType.dateTime,
    ),
    r'shopItemId': PropertySchema(
      id: 3,
      name: r'shopItemId',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _ownedItemCollectionEstimateSize,
  serialize: _ownedItemCollectionSerialize,
  deserialize: _ownedItemCollectionDeserialize,
  deserializeProp: _ownedItemCollectionDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ownedItemCollectionGetId,
  getLinks: _ownedItemCollectionGetLinks,
  attach: _ownedItemCollectionAttach,
  version: '3.1.0+1',
);

int _ownedItemCollectionEstimateSize(
  OwnedItemCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.shopItemId.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _ownedItemCollectionSerialize(
  OwnedItemCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.id);
  writer.writeBool(offsets[1], object.isEquipped);
  writer.writeDateTime(offsets[2], object.purchasedAt);
  writer.writeString(offsets[3], object.shopItemId);
  writer.writeString(offsets[4], object.userId);
}

OwnedItemCollection _ownedItemCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OwnedItemCollection();
  object.id = reader.readString(offsets[0]);
  object.isEquipped = reader.readBool(offsets[1]);
  object.isarId = id;
  object.purchasedAt = reader.readDateTime(offsets[2]);
  object.shopItemId = reader.readString(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _ownedItemCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ownedItemCollectionGetId(OwnedItemCollection object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _ownedItemCollectionGetLinks(
    OwnedItemCollection object) {
  return [];
}

void _ownedItemCollectionAttach(
    IsarCollection<dynamic> col, Id id, OwnedItemCollection object) {
  object.isarId = id;
}

extension OwnedItemCollectionQueryWhereSort
    on QueryBuilder<OwnedItemCollection, OwnedItemCollection, QWhere> {
  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OwnedItemCollectionQueryWhere
    on QueryBuilder<OwnedItemCollection, OwnedItemCollection, QWhereClause> {
  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterWhereClause>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterWhereClause>
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

extension OwnedItemCollectionQueryFilter on QueryBuilder<OwnedItemCollection,
    OwnedItemCollection, QFilterCondition> {
  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      isEquippedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEquipped',
        value: value,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      purchasedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchasedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      purchasedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchasedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      purchasedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchasedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      purchasedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchasedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shopItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shopItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shopItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shopItemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shopItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shopItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shopItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shopItemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shopItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      shopItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shopItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
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

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension OwnedItemCollectionQueryObject on QueryBuilder<OwnedItemCollection,
    OwnedItemCollection, QFilterCondition> {}

extension OwnedItemCollectionQueryLinks on QueryBuilder<OwnedItemCollection,
    OwnedItemCollection, QFilterCondition> {}

extension OwnedItemCollectionQuerySortBy
    on QueryBuilder<OwnedItemCollection, OwnedItemCollection, QSortBy> {
  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByIsEquipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEquipped', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByIsEquippedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEquipped', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByShopItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopItemId', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByShopItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopItemId', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension OwnedItemCollectionQuerySortThenBy
    on QueryBuilder<OwnedItemCollection, OwnedItemCollection, QSortThenBy> {
  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByIsEquipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEquipped', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByIsEquippedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEquipped', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByShopItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopItemId', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByShopItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shopItemId', Sort.desc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension OwnedItemCollectionQueryWhereDistinct
    on QueryBuilder<OwnedItemCollection, OwnedItemCollection, QDistinct> {
  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QDistinct>
      distinctByIsEquipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEquipped');
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QDistinct>
      distinctByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasedAt');
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QDistinct>
      distinctByShopItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shopItemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OwnedItemCollection, OwnedItemCollection, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension OwnedItemCollectionQueryProperty
    on QueryBuilder<OwnedItemCollection, OwnedItemCollection, QQueryProperty> {
  QueryBuilder<OwnedItemCollection, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<OwnedItemCollection, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OwnedItemCollection, bool, QQueryOperations>
      isEquippedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEquipped');
    });
  }

  QueryBuilder<OwnedItemCollection, DateTime, QQueryOperations>
      purchasedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasedAt');
    });
  }

  QueryBuilder<OwnedItemCollection, String, QQueryOperations>
      shopItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shopItemId');
    });
  }

  QueryBuilder<OwnedItemCollection, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
