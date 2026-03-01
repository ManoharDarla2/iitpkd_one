import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/services/hive_service.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';

/// Repository that manages shuttle schedule data.
///
/// Implements a cache-first strategy using Hive:
/// 1. Check if cached data exists and is within the 7-day TTL.
/// 2. If valid cache exists, return cached data.
/// 3. Otherwise, fetch from API, cache the result, and return.
class ShuttleRepository {
  final ApiClientInterface _apiClient;
  final HiveService _hiveService;

  ShuttleRepository({
    required ApiClientInterface apiClient,
    required HiveService hiveService,
  }) : _apiClient = apiClient,
       _hiveService = hiveService;

  /// Fetches shuttle schedules for the given [day].
  ///
  /// Uses cached data if available and valid.
  /// Set [forceRefresh] to true to bypass the cache.
  Future<List<ShuttleSchedule>> getSchedules({
    required String day,
    bool forceRefresh = false,
  }) async {
    // Try cache first (unless forced refresh)
    if (!forceRefresh && _hiveService.isShuttleCacheValid()) {
      final cached = _hiveService.getCachedShuttleData();
      if (cached != null) {
        final allSchedules = ShuttleSchedule.decodeList(cached);
        return _filterByDay(allSchedules, day);
      }
    }

    // Fetch from API
    final response = await _apiClient.getShuttleSchedules(day: null);

    if (response.isError || response.data == null) {
      // If API fails but we have stale cache, return that
      final staleCache = _hiveService.getCachedShuttleData();
      if (staleCache != null) {
        final allSchedules = ShuttleSchedule.decodeList(staleCache);
        return _filterByDay(allSchedules, day);
      }
      throw Exception(response.error ?? 'Failed to fetch shuttle schedules');
    }

    // Cache the full (unfiltered) response
    final allSchedules = response.data!;
    await _hiveService.cacheShuttleData(
      ShuttleSchedule.encodeList(allSchedules),
    );

    return _filterByDay(allSchedules, day);
  }

  /// Filters schedules to only include those running on [day].
  List<ShuttleSchedule> _filterByDay(
    List<ShuttleSchedule> schedules,
    String day,
  ) {
    return schedules.where((s) => s.runsOnDay(day)).toList();
  }
}
