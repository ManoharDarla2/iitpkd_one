import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central location for all API endpoint paths and configuration.
abstract final class ApiConstants {
  /// Base URL for the backend server.
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.128.8.171:3000';

  /// API version prefix.
  static const String apiVersion = '/api/v1';

  // -- Shuttle endpoints --
  static const String shuttleSchedules = '$apiVersion/shuttles';
  static const String shuttleMetadata = '$apiVersion/shuttles/metadata';

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

  // -- Competition endpoints --
  static const String competitions = '$apiVersion/competitions';

  // -- Colab endpoints --
  static const String colabs = '$apiVersion/colabs';
  static const String colabDetail = '$apiVersion/colabs'; // append /:id
  static const String colabRequests = '$apiVersion/colabs/requests';
  static const String colabJoinRequest = '$apiVersion/colabs/requests/join';
  static const String colabInviteRequest = '$apiVersion/colabs/requests/invite';
  static const String colabAcceptRequest = '$apiVersion/colabs/requests/accept';
  static const String colabRejectRequest = '$apiVersion/colabs/requests/reject';

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

  // -- Colab cache --
  static const String colabCacheBox = 'colab_cache';
  static const String colabListKey = 'colab_list';
  static const String colabListLastFetchedKey = 'colab_list_last_fetched';
  static const Duration colabCacheTtl = Duration(minutes: 30);

  // -- Cache durations --
  static const Duration shuttleCacheTtl = Duration(days: 7);
  static const Duration messCacheTtl = Duration(days: 30);
}
