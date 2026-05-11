import 'package:csquare_connect/core/network/api_client_interface.dart';
import 'package:csquare_connect/core/services/hive_service.dart';
import 'package:csquare_connect/features/schedule/data/models/mess_menu.dart';

/// Repository that manages mess menu data.
///
/// Implements a cache-first strategy using Hive with metadata-based
/// invalidation:
/// 1. Check if Hive has cached data and TTL is valid.
/// 2. If valid, return cached data.
/// 3. Otherwise, check `/mess/metadata` updated_at vs local timestamp.
/// 4. If stale (or no cache), fetch full menu via `/mess/menu`, cache it.
/// 5. Fallback to stale cache on network error.
///
/// Also caches the server's [calculatedWeek] so the frontend uses the
/// server-determined week type instead of a local hardcoded calculation.
class MessRepository {
  final ApiClientInterface _apiClient;
  final HiveService _hiveService;

  MessRepository({
    required ApiClientInterface apiClient,
    required HiveService hiveService,
  }) : _apiClient = apiClient,
       _hiveService = hiveService;

  /// Returns the server-determined current week type, with a local
  /// fallback calculation if no server value has been cached yet.
  String getCachedWeekType() {
    final server = _hiveService.getCachedMessCalculatedWeek();
    if (server != null) return server;
    return _localFallback();
  }

  static String _localFallback() {
    final reference = DateTime(2026, 1, 5);
    final weeksDiff = DateTime.now().difference(reference).inDays ~/ 7;
    return weeksDiff.isEven ? 'odd' : 'even';
  }

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
          final meta = metaResponse.data!;
          final serverTimestamp = meta.updatedAt.toIso8601String();
          final localTimestamp = _hiveService.getCachedMessMetadataTimestamp();

          if (meta.calculatedWeek != null) {
            await _hiveService.cacheMessCalculatedWeek(meta.calculatedWeek!);
          }

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

    // Store metadata timestamp and calculatedWeek for future comparisons
    try {
      final metaResponse = await _apiClient.getMessMetadata();
      if (metaResponse.data != null) {
        final meta = metaResponse.data!;
        await _hiveService.cacheMessMetadataTimestamp(
          meta.updatedAt.toIso8601String(),
        );
        if (meta.calculatedWeek != null) {
          await _hiveService.cacheMessCalculatedWeek(meta.calculatedWeek!);
        }
      }
    } catch (_) {
      // Non-critical: metadata caching failed
    }

    return menu;
  }
}
