import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/search/view_models/providers.dart';

/// Riverpod provider for recent searches state.
final recentSearchesViewModelProvider =
    NotifierProvider<RecentSearchesViewModel, List<String>>(
      RecentSearchesViewModel.new,
    );

/// ViewModel that manages the recent search queries.
///
/// Backed by Hive persistence via [RecentSearchRepository].
/// State is a simple list of query strings, most recent first.
class RecentSearchesViewModel extends Notifier<List<String>> {
  @override
  List<String> build() {
    final repo = ref.read(recentSearchRepositoryProvider);
    return repo.getRecentSearches();
  }

  /// Adds a query to recent searches and updates state.
  Future<void> addSearch(String query) async {
    final repo = ref.read(recentSearchRepositoryProvider);
    await repo.addRecentSearch(query);
    state = repo.getRecentSearches();
  }

  /// Removes a single query from recent searches.
  Future<void> removeSearch(String query) async {
    final repo = ref.read(recentSearchRepositoryProvider);
    await repo.removeRecentSearch(query);
    state = repo.getRecentSearches();
  }

  /// Clears all recent searches.
  Future<void> clearAll() async {
    final repo = ref.read(recentSearchRepositoryProvider);
    await repo.clearRecentSearches();
    state = [];
  }
}
