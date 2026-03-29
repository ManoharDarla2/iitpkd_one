/// Central location for all API endpoint paths and configuration.
abstract final class ApiConstants {
  /// Base URL for the backend server.
  /// Override using: --dart-define=API_BASE_URL=http://host:port
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.32.11.107:3000',
  );

  /// API version prefix.
  static const String apiVersion = '/api/v1';

  // -- Shuttle endpoints --
  static const String shuttleSchedules = '$apiVersion/shuttles';
  static const String shuttleMetadata = '$apiVersion/shuttles/metadata';

  // -- Notice endpoints --
  static const String todayNotices = '$apiVersion/notices/today';
  static const String notices = '$apiVersion/notices';

  // -- Mess endpoints --
  static const String messMenu = '$apiVersion/mess/menu';
  static const String messMenuToday = '$apiVersion/mess/menu/today';
  static const String messMetadata = '$apiVersion/mess/metadata';

  // -- Faculty endpoints --
  static const String facultyList = '$apiVersion/faculty';
  static const String facultyDetail = '$apiVersion/faculty'; // append /:slug

  // -- Search endpoints --
  static const String search = '$apiVersion/search';
  static const String searchSuggestions = '$apiVersion/search/suggestions';

  // -- Hive box names --
  static const String shuttleCacheBox = 'shuttle_cache';
  static const String shuttleDataKey = 'shuttle_schedules';
  static const String shuttleLastFetchedKey = 'shuttle_last_fetched';

  static const String messCacheBox = 'mess_cache';
  static const String messDataKey = 'mess_menu';
  static const String messLastFetchedKey = 'mess_last_fetched';
  static const String messMetadataKey = 'mess_metadata_updated_at';

  static const String recentSearchesBox = 'recent_searches';
  static const String recentSearchesKey = 'recent_queries';
  static const int recentSearchesMaxCount = 10;

  // -- Cache durations --
  static const Duration shuttleCacheTtl = Duration(days: 7);
  static const Duration messCacheTtl = Duration(days: 30);

  // -- Mock network delay --
  static const Duration mockNetworkDelay = Duration(milliseconds: 800);
}
