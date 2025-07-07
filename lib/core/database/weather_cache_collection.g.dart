// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_cache_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeatherCacheCollectionCollection on Isar {
  IsarCollection<WeatherCacheCollection> get weatherCacheCollections =>
      this.collection();
}

const WeatherCacheCollectionSchema = CollectionSchema(
  name: r'WeatherCacheCollection',
  id: 4386510115388283076,
  properties: {
    r'cacheKey': PropertySchema(
      id: 0,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 1,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'locationKey': PropertySchema(
      id: 2,
      name: r'locationKey',
      type: IsarType.string,
    ),
    r'weatherData': PropertySchema(
      id: 3,
      name: r'weatherData',
      type: IsarType.string,
    )
  },
  estimateSize: _weatherCacheCollectionEstimateSize,
  serialize: _weatherCacheCollectionSerialize,
  deserialize: _weatherCacheCollectionDeserialize,
  deserializeProp: _weatherCacheCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _weatherCacheCollectionGetId,
  getLinks: _weatherCacheCollectionGetLinks,
  attach: _weatherCacheCollectionAttach,
  version: '3.1.0+1',
);

int _weatherCacheCollectionEstimateSize(
  WeatherCacheCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.locationKey.length * 3;
  bytesCount += 3 + object.weatherData.length * 3;
  return bytesCount;
}

void _weatherCacheCollectionSerialize(
  WeatherCacheCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheKey);
  writer.writeDateTime(offsets[1], object.lastUpdated);
  writer.writeString(offsets[2], object.locationKey);
  writer.writeString(offsets[3], object.weatherData);
}

WeatherCacheCollection _weatherCacheCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeatherCacheCollection();
  object.cacheKey = reader.readString(offsets[0]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[1]);
  object.locationKey = reader.readString(offsets[2]);
  object.weatherData = reader.readString(offsets[3]);
  return object;
}

P _weatherCacheCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weatherCacheCollectionGetId(WeatherCacheCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weatherCacheCollectionGetLinks(
    WeatherCacheCollection object) {
  return [];
}

void _weatherCacheCollectionAttach(
    IsarCollection<dynamic> col, Id id, WeatherCacheCollection object) {
  object.id = id;
}

extension WeatherCacheCollectionQueryWhereSort
    on QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QWhere> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WeatherCacheCollectionQueryWhere on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QWhereClause> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> cacheKeyEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cacheKey',
        value: [cacheKey],
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> cacheKeyNotEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WeatherCacheCollectionQueryFilter on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QFilterCondition> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      locationKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      locationKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationKey',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationKey',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weatherData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weatherData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weatherData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weatherData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weatherData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      weatherDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weatherData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      weatherDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weatherData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherData',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weatherData',
        value: '',
      ));
    });
  }
}

extension WeatherCacheCollectionQueryObject on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QFilterCondition> {}

extension WeatherCacheCollectionQueryLinks on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QFilterCondition> {}

extension WeatherCacheCollectionQuerySortBy
    on QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QSortBy> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLocationKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationKey', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLocationKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationKey', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByWeatherData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherData', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByWeatherDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherData', Sort.desc);
    });
  }
}

extension WeatherCacheCollectionQuerySortThenBy on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QSortThenBy> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLocationKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationKey', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLocationKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationKey', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByWeatherData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherData', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByWeatherDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherData', Sort.desc);
    });
  }
}

extension WeatherCacheCollectionQueryWhereDistinct
    on QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByCacheKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByLocationKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByWeatherData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weatherData', caseSensitive: caseSensitive);
    });
  }
}

extension WeatherCacheCollectionQueryProperty on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QQueryProperty> {
  QueryBuilder<WeatherCacheCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeatherCacheCollection, String, QQueryOperations>
      cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<WeatherCacheCollection, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<WeatherCacheCollection, String, QQueryOperations>
      locationKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationKey');
    });
  }

  QueryBuilder<WeatherCacheCollection, String, QQueryOperations>
      weatherDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherData');
    });
  }
}
