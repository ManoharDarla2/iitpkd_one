import 'package:iitpkd_one/core/services/hive_service.dart';

/// Repository that manages recent search queries via Hive.
///
/// Delegates all persistence to [HiveService]. Provides a clean
/// interface for the ViewModel layer to manage search history.
class RecentSearchRepository {
  final HiveService _hiveService;

  RecentSearchRepository({required HiveService hiveService})
    : _hiveService = hiveService;

  /// Returns the list of recent search queries, most recent first.
  List<String> getRecentSearches() {
    return _hiveService.getRecentSearches();
  }

  /// Adds a query to recent searches (deduplicates, caps at max count).
  Future<void> addRecentSearch(String query) async {
    await _hiveService.addRecentSearch(query);
  }

  /// Removes a single query from recent searches.
  Future<void> removeRecentSearch(String query) async {
    await _hiveService.removeRecentSearch(query);
  }

  /// Clears all recent searches.
  Future<void> clearRecentSearches() async {
    await _hiveService.clearRecentSearches();
  }
}
