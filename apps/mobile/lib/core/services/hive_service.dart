import 'package:hive_flutter/hive_flutter.dart';
import 'package:iitpkd_one/core/constants/api_constants.dart';

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
  }

  /// Stores the server's metadata `updated_at` timestamp for comparison.
  Future<void> cacheMessMetadataTimestamp(String updatedAt) async {
    await messBox.put(ApiConstants.messMetadataKey, updatedAt);
  }

  /// Retrieves the cached metadata `updated_at` timestamp, or null.
  String? getCachedMessMetadataTimestamp() {
    return messBox.get(ApiConstants.messMetadataKey);
  }
}
