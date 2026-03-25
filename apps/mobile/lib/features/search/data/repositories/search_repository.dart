import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/features/search/data/models/search_result.dart';

/// Repository that manages search data.
///
/// Uses a network-first approach (no caching) since search results
/// depend on the query and must always reflect the latest data.
class SearchRepository {
  final ApiClientInterface _apiClient;

  SearchRepository({required ApiClientInterface apiClient})
    : _apiClient = apiClient;

  /// Performs a search with the given [query].
  ///
  /// Optionally filters by [category] and caps results at [limit].
  Future<SearchResult> search({
    required String query,
    String? category,
    int? limit,
  }) async {
    final response = await _apiClient.search(
      query: query,
      category: category,
      limit: limit,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to perform search');
    }

    return response.data!;
  }

  /// Fetches autocomplete suggestions for the given [query] prefix.
  Future<List<String>> getSuggestions({required String query}) async {
    final response = await _apiClient.getSearchSuggestions(query: query);

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch suggestions');
    }

    return response.data!;
  }
}
