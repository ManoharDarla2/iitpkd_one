import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';
import 'package:iitpkd_one/features/search/data/repositories/recent_search_repository.dart';
import 'package:iitpkd_one/features/search/data/repositories/search_repository.dart';

/// -- Dependency Injection Providers for the Search feature --

/// Provides the search repository with its dependencies injected.
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(apiClient: ref.watch(apiClientProvider)),
);

/// Provides the recent search repository with Hive service injected.
final recentSearchRepositoryProvider = Provider<RecentSearchRepository>(
  (ref) => RecentSearchRepository(hiveService: ref.watch(hiveServiceProvider)),
);

/// Provides autocomplete suggestions for a given query prefix.
///
/// Uses [FutureProvider.family] so each query prefix gets its own
/// independent loading state. Auto-disposed when no longer watched.
final searchSuggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      final repo = ref.read(searchRepositoryProvider);
      return repo.getSuggestions(query: query);
    });
