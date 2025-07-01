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
    r'cachedAt': PropertySchema(
      id: 0,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'latitude': PropertySchema(
      id: 1,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'locationKey': PropertySchema(
      id: 2,
      name: r'locationKey',
      type: IsarType.string,
    ),
    r'locationName': PropertySchema(
      id: 3,
      name: r'locationName',
      type: IsarType.string,
    ),
    r'longitude': PropertySchema(
      id: 4,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'weatherDataJson': PropertySchema(
      id: 5,
      name: r'weatherDataJson',
      type: IsarType.string,
    )
  },
  estimateSize: _weatherCacheCollectionEstimateSize,
  serialize: _weatherCacheCollectionSerialize,
  deserialize: _weatherCacheCollectionDeserialize,
  deserializeProp: _weatherCacheCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'locationKey': IndexSchema(
      id: 1950685211417560871,
      name: r'locationKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'locationKey',
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
  bytesCount += 3 + object.locationKey.length * 3;
  bytesCount += 3 + object.locationName.length * 3;
  bytesCount += 3 + object.weatherDataJson.length * 3;
  return bytesCount;
}

void _weatherCacheCollectionSerialize(
  WeatherCacheCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.cachedAt);
  writer.writeDouble(offsets[1], object.latitude);
  writer.writeString(offsets[2], object.locationKey);
  writer.writeString(offsets[3], object.locationName);
  writer.writeDouble(offsets[4], object.longitude);
  writer.writeString(offsets[5], object.weatherDataJson);
}

WeatherCacheCollection _weatherCacheCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeatherCacheCollection();
  object.cachedAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.latitude = reader.readDouble(offsets[1]);
  object.locationKey = reader.readString(offsets[2]);
  object.locationName = reader.readString(offsets[3]);
  object.longitude = reader.readDouble(offsets[4]);
  object.weatherDataJson = reader.readString(offsets[5]);
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
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
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

extension WeatherCacheCollectionByIndex
    on IsarCollection<WeatherCacheCollection> {
  Future<WeatherCacheCollection?> getByLocationKey(String locationKey) {
    return getByIndex(r'locationKey', [locationKey]);
  }

  WeatherCacheCollection? getByLocationKeySync(String locationKey) {
    return getByIndexSync(r'locationKey', [locationKey]);
  }

  Future<bool> deleteByLocationKey(String locationKey) {
    return deleteByIndex(r'locationKey', [locationKey]);
  }

  bool deleteByLocationKeySync(String locationKey) {
    return deleteByIndexSync(r'locationKey', [locationKey]);
  }

  Future<List<WeatherCacheCollection?>> getAllByLocationKey(
      List<String> locationKeyValues) {
    final values = locationKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'locationKey', values);
  }

  List<WeatherCacheCollection?> getAllByLocationKeySync(
      List<String> locationKeyValues) {
    final values = locationKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'locationKey', values);
  }

  Future<int> deleteAllByLocationKey(List<String> locationKeyValues) {
    final values = locationKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'locationKey', values);
  }

  int deleteAllByLocationKeySync(List<String> locationKeyValues) {
    final values = locationKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'locationKey', values);
  }

  Future<Id> putByLocationKey(WeatherCacheCollection object) {
    return putByIndex(r'locationKey', object);
  }

  Id putByLocationKeySync(WeatherCacheCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'locationKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocationKey(List<WeatherCacheCollection> objects) {
    return putAllByIndex(r'locationKey', objects);
  }

  List<Id> putAllByLocationKeySync(List<WeatherCacheCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'locationKey', objects, saveLinks: saveLinks);
  }
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
      QAfterWhereClause> locationKeyEqualTo(String locationKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'locationKey',
        value: [locationKey],
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterWhereClause> locationKeyNotEqualTo(String locationKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationKey',
              lower: [],
              upper: [locationKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationKey',
              lower: [locationKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationKey',
              lower: [locationKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationKey',
              lower: [],
              upper: [locationKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WeatherCacheCollectionQueryFilter on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QFilterCondition> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cachedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cachedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> cachedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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
      QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
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
      QAfterFilterCondition> locationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      locationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      locationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationName',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> locationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationName',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weatherDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weatherDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weatherDataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weatherDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weatherDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      weatherDataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weatherDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
          QAfterFilterCondition>
      weatherDataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weatherDataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection,
      QAfterFilterCondition> weatherDataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weatherDataJson',
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
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
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
      sortByLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByWeatherDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherDataJson', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      sortByWeatherDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherDataJson', Sort.desc);
    });
  }
}

extension WeatherCacheCollectionQuerySortThenBy on QueryBuilder<
    WeatherCacheCollection, WeatherCacheCollection, QSortThenBy> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
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
      thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
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
      thenByLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByWeatherDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherDataJson', Sort.asc);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QAfterSortBy>
      thenByWeatherDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherDataJson', Sort.desc);
    });
  }
}

extension WeatherCacheCollectionQueryWhereDistinct
    on QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct> {
  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByLocationKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByLocationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<WeatherCacheCollection, WeatherCacheCollection, QDistinct>
      distinctByWeatherDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weatherDataJson',
          caseSensitive: caseSensitive);
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

  QueryBuilder<WeatherCacheCollection, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<WeatherCacheCollection, double, QQueryOperations>
      latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<WeatherCacheCollection, String, QQueryOperations>
      locationKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationKey');
    });
  }

  QueryBuilder<WeatherCacheCollection, String, QQueryOperations>
      locationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationName');
    });
  }

  QueryBuilder<WeatherCacheCollection, double, QQueryOperations>
      longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<WeatherCacheCollection, String, QQueryOperations>
      weatherDataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherDataJson');
    });
  }
}
