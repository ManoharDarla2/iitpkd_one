import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/search/data/models/search_category.dart';
import 'package:iitpkd_one/features/search/data/models/search_result.dart';
import 'package:iitpkd_one/features/search/view_models/providers.dart';

/// Riverpod provider for the search view model.
final searchViewModelProvider =
    AsyncNotifierProvider<SearchViewModel, SearchResult?>(SearchViewModel.new);

/// ViewModel that manages the search screen state.
///
/// Handles query changes, category filtering, and triggers API calls.
/// The debounce logic lives in the UI layer (via flutter_hooks Timer),
/// so this ViewModel receives already-debounced queries.
class SearchViewModel extends AsyncNotifier<SearchResult?> {
  /// The current search query.
  String _currentQuery = '';

  /// The currently selected category filter (null = all).
  SearchCategory? _currentCategory;

  String? _toBackendCategory(SearchCategory? category) {
    if (category == null) return null;
    return switch (category) {
      SearchCategory.equipment => 'equipment',
      SearchCategory.faculty => 'faculty',
      SearchCategory.schedule => 'schedule',
      SearchCategory.people => 'faculty',
      SearchCategory.labs => 'schedule',
      SearchCategory.schedules => 'schedule',
    };
  }

  /// Returns the current query.
  String get currentQuery => _currentQuery;

  /// Returns the currently selected category.
  SearchCategory? get currentCategory => _currentCategory;

  @override
  Future<SearchResult?> build() async {
    // No initial search — show the empty/suggestions state.
    return null;
  }

  /// Updates the search query and triggers a new search.
  ///
  /// Called by the debounce timer in the UI after the user stops typing.
  Future<void> updateQuery(String query) async {
    _currentQuery = query.trim();

    if (_currentQuery.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(searchRepositoryProvider);
      return repo.search(
        query: _currentQuery,
        category: _toBackendCategory(_currentCategory),
      );
    });
  }

  /// Updates the category filter and re-triggers the search.
  ///
  /// Pass null to clear the filter (show all categories).
  Future<void> updateCategory(SearchCategory? category) async {
    _currentCategory = category;

    // Only re-search if there's an active query.
    if (_currentQuery.isNotEmpty) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final repo = ref.read(searchRepositoryProvider);
        return repo.search(
          query: _currentQuery,
          category: _toBackendCategory(_currentCategory),
        );
      });
    }
  }

  /// Clears the search state back to initial (no query, no results).
  void clearSearch() {
    _currentQuery = '';
    _currentCategory = null;
    state = const AsyncValue.data(null);
  }
}
