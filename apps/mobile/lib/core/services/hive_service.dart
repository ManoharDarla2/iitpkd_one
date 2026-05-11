import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:csquare_connect/core/constants/api_constants.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';

/// Service responsible for initializing Hive and managing box access.
///
/// Shuttle and mess schedules are stored as JSON strings with a TTL timestamp
/// to determine when a refresh from the server is needed.
class HiveService {
  bool _initialized = false;

  /// Initialize Hive and open required boxes.
  /// Must be called once at app startup before any Hive operations.
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<String>(ApiConstants.shuttleCacheBox);
    await Hive.openBox<String>(ApiConstants.messCacheBox);
    await Hive.openBox<String>(ApiConstants.recentSearchesBox);
    await Hive.openBox<String>(ApiConstants.colabCacheBox);
    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // Shuttle cache
  // ---------------------------------------------------------------------------

  /// Returns the shuttle cache box.
  Box<String> get shuttleBox => Hive.box<String>(ApiConstants.shuttleCacheBox);

  /// Stores shuttle schedule JSON data and records the fetch timestamp.
  Future<void> cacheShuttleData(String jsonData) async {
    final box = shuttleBox;
    await box.put(ApiConstants.shuttleDataKey, jsonData);
    await box.put(
      ApiConstants.shuttleLastFetchedKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Retrieves cached shuttle schedule JSON data, or null if not cached.
  String? getCachedShuttleData() {
    return shuttleBox.get(ApiConstants.shuttleDataKey);
  }

  /// Returns true if the shuttle cache is still valid (within TTL).
  bool isShuttleCacheValid() {
    final lastFetchedStr = shuttleBox.get(ApiConstants.shuttleLastFetchedKey);
    if (lastFetchedStr == null) return false;

    final lastFetched = DateTime.tryParse(lastFetchedStr);
    if (lastFetched == null) return false;

    return DateTime.now().difference(lastFetched) <
        ApiConstants.shuttleCacheTtl;
  }

  /// Clears the shuttle cache, forcing a fresh fetch next time.
  Future<void> clearShuttleCache() async {
    final box = shuttleBox;
    await box.delete(ApiConstants.shuttleDataKey);
    await box.delete(ApiConstants.shuttleLastFetchedKey);
  }

  // ---------------------------------------------------------------------------
  // Mess cache
  // ---------------------------------------------------------------------------

  /// Returns the mess cache box.
  Box<String> get messBox => Hive.box<String>(ApiConstants.messCacheBox);

  /// Stores mess menu JSON data and records the fetch timestamp.
  Future<void> cacheMessData(String jsonData) async {
    final box = messBox;
    await box.put(ApiConstants.messDataKey, jsonData);
    await box.put(
      ApiConstants.messLastFetchedKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Retrieves cached mess menu JSON data, or null if not cached.
  String? getCachedMessData() {
    return messBox.get(ApiConstants.messDataKey);
  }

  /// Returns true if the mess cache is still valid (within TTL).
  bool isMessCacheValid() {
    final lastFetchedStr = messBox.get(ApiConstants.messLastFetchedKey);
    if (lastFetchedStr == null) return false;

    final lastFetched = DateTime.tryParse(lastFetchedStr);
    if (lastFetched == null) return false;

    return DateTime.now().difference(lastFetched) < ApiConstants.messCacheTtl;
  }

  /// Clears the mess cache, forcing a fresh fetch next time.
  Future<void> clearMessCache() async {
    final box = messBox;
    await box.delete(ApiConstants.messDataKey);
    await box.delete(ApiConstants.messLastFetchedKey);
    await box.delete(ApiConstants.messMetadataKey);
    await box.delete(ApiConstants.messCalculatedWeekKey);
  }

  /// Stores the server's metadata `updated_at` timestamp for comparison.
  Future<void> cacheMessMetadataTimestamp(String updatedAt) async {
    await messBox.put(ApiConstants.messMetadataKey, updatedAt);
  }

  /// Retrieves the cached metadata `updated_at` timestamp, or null.
  String? getCachedMessMetadataTimestamp() {
    return messBox.get(ApiConstants.messMetadataKey);
  }

  /// Caches the server-determined current week type ("odd"/"even").
  Future<void> cacheMessCalculatedWeek(String weekType) async {
    await messBox.put(ApiConstants.messCalculatedWeekKey, weekType);
  }

  /// Retrieves the cached calculated week type, or null.
  String? getCachedMessCalculatedWeek() {
    return messBox.get(ApiConstants.messCalculatedWeekKey);
  }

  // ---------------------------------------------------------------------------
  // Recent searches
  // ---------------------------------------------------------------------------

  /// Returns the recent searches box.
  Box<String> get recentSearchesBox =>
      Hive.box<String>(ApiConstants.recentSearchesBox);

  /// Returns the list of recent search queries, most recent first.
  List<String> getRecentSearches() {
    final raw = recentSearchesBox.get(ApiConstants.recentSearchesKey);
    if (raw == null || raw.isEmpty) return [];
    return raw.split('\n');
  }

  /// Adds a query to the front of the recent searches list.
  /// Deduplicates and caps at [ApiConstants.recentSearchesMaxCount].
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final current = getRecentSearches();
    current.remove(trimmed);
    current.insert(0, trimmed);

    final capped = current.take(ApiConstants.recentSearchesMaxCount).toList();
    await recentSearchesBox.put(
      ApiConstants.recentSearchesKey,
      capped.join('\n'),
    );
  }

  /// Removes a single query from recent searches.
  Future<void> removeRecentSearch(String query) async {
    final current = getRecentSearches();
    current.remove(query.trim());
    await recentSearchesBox.put(
      ApiConstants.recentSearchesKey,
      current.join('\n'),
    );
  }

  /// Clears all recent searches.
  Future<void> clearRecentSearches() async {
    await recentSearchesBox.delete(ApiConstants.recentSearchesKey);
  }

  // ---------------------------------------------------------------------------
  // Colab cache
  // ---------------------------------------------------------------------------

  /// Returns the colab cache box.
  Box<String> get colabBox => Hive.box<String>(ApiConstants.colabCacheBox);

  /// Stores colab list JSON data and records the fetch timestamp.
  Future<void> cacheColabList(String jsonData) async {
    final box = colabBox;
    await box.put(ApiConstants.colabListKey, jsonData);
    await box.put(
      ApiConstants.colabListLastFetchedKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Retrieves cached colab list JSON data, or null if not cached.
  List<ColabItem>? getCachedColabList() {
    final jsonStr = colabBox.get(ApiConstants.colabListKey);
    if (jsonStr == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => ColabItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Returns true if the colab cache is still valid (within TTL).
  bool isColabCacheValid() {
    final lastFetchedStr = colabBox.get(ApiConstants.colabListLastFetchedKey);
    if (lastFetchedStr == null) return false;

    final lastFetched = DateTime.tryParse(lastFetchedStr);
    if (lastFetched == null) return false;

    return DateTime.now().difference(lastFetched) < ApiConstants.colabCacheTtl;
  }

  /// Clears the colab cache, forcing a fresh fetch next time.
  Future<void> clearColabCache() async {
    final box = colabBox;
    await box.delete(ApiConstants.colabListKey);
    await box.delete(ApiConstants.colabListLastFetchedKey);
  }
}
