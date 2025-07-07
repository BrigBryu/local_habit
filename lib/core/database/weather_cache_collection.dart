import 'package:isar/isar.dart';

part 'weather_cache_collection.g.dart';

@collection
class WeatherCacheCollection {
  Id id = Isar.autoIncrement;
  
  late String locationKey;
  late String weatherData; // JSON string
  late DateTime lastUpdated;
  
  @Index()
  late String cacheKey; // Combined location + date key for efficient lookup
  
  WeatherCacheCollection();
  
  WeatherCacheCollection.create({
    required this.locationKey,
    required this.weatherData,
    required this.lastUpdated,
    required this.cacheKey,
  });
}