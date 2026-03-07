import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/services/hive_service.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_menu.dart';

/// Repository that manages mess menu data.
///
/// Implements a cache-first strategy using Hive with metadata-based
/// invalidation:
/// 1. Check if Hive has cached data and TTL is valid.
/// 2. If valid, return cached data.
/// 3. Otherwise, check `/mess/metadata` updated_at vs local timestamp.
/// 4. If stale (or no cache), fetch full menu via `/mess/menu`, cache it.
/// 5. Fallback to stale cache on network error.
class MessRepository {
  final ApiClientInterface _apiClient;
  final HiveService _hiveService;

  MessRepository({
    required ApiClientInterface apiClient,
    required HiveService hiveService,
  }) : _apiClient = apiClient,
       _hiveService = hiveService;

  /// Fetches the full 14-day mess menu.
  ///
  /// Uses cached data if available and valid.
  /// Set [forceRefresh] to true to bypass the cache.
  Future<MessMenu> getFullMenu({bool forceRefresh = false}) async {
    // Try cache first (unless forced refresh)
    if (!forceRefresh && _hiveService.isMessCacheValid()) {
      final cached = _hiveService.getCachedMessData();
      if (cached != null) {
        return MessMenu.decode(cached);
      }
    }

    // Check metadata to see if our cache is stale
    if (!forceRefresh) {
      try {
        final metaResponse = await _apiClient.getMessMetadata();
        if (metaResponse.data != null) {
          final serverTimestamp = metaResponse.data!.updatedAt.toIso8601String();
          final localTimestamp = _hiveService.getCachedMessMetadataTimestamp();

          if (localTimestamp == serverTimestamp) {
            // Server data hasn't changed, use cache if available
            final cached = _hiveService.getCachedMessData();
            if (cached != null) {
              return MessMenu.decode(cached);
            }
          }
        }
      } catch (_) {
        // Metadata check failed; proceed to full fetch
      }
    }

    // Fetch from API
    final response = await _apiClient.getMessMenu();

    if (response.isError || response.data == null) {
      // If API fails but we have stale cache, return that
      final staleCache = _hiveService.getCachedMessData();
      if (staleCache != null) {
        return MessMenu.decode(staleCache);
      }
      throw Exception(response.error ?? 'Failed to fetch mess menu');
    }

    // Cache the response
    final menu = response.data!;
    await _hiveService.cacheMessData(menu.encode());

    // Store metadata timestamp for future comparisons
    try {
      final metaResponse = await _apiClient.getMessMetadata();
      if (metaResponse.data != null) {
        await _hiveService.cacheMessMetadataTimestamp(
          metaResponse.data!.updatedAt.toIso8601String(),
        );
      }
    } catch (_) {
      // Non-critical: metadata caching failed
    }

    return menu;
  }
}
