/// Central location for all API endpoint paths and configuration.
abstract final class ApiConstants {
  /// Base URL for the backend server.
  /// Change this when deploying to staging/production.
  static const String baseUrl = 'https://api.iitpkd.ac.in';

  /// API version prefix.
  static const String apiVersion = '/api/v1';

  // -- Shuttle endpoints --
  static const String shuttleSchedules = '$apiVersion/shuttles';

  // -- Notice endpoints --
  static const String todayNotices = '$apiVersion/notices/today';
  static const String notices = '$apiVersion/notices';

  // -- Hive box names --
  static const String shuttleCacheBox = 'shuttle_cache';
  static const String shuttleDataKey = 'shuttle_schedules';
  static const String shuttleLastFetchedKey = 'shuttle_last_fetched';

  // -- Cache durations --
  static const Duration shuttleCacheTtl = Duration(days: 7);

  // -- Mock network delay --
  static const Duration mockNetworkDelay = Duration(milliseconds: 800);
}
