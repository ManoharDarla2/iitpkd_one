import 'package:iitpkd_one/features/search/data/models/search_result_item.dart';

/// Top-level response model for the search endpoint.
///
/// Maps to GET /api/v1/search response body's `data` field.
class SearchResult {
  final String query;
  final String? category;
  final int totalCount;
  final List<SearchResultItem> results;

  const SearchResult({
    required this.query,
    this.category,
    required this.totalCount,
    required this.results,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      query: json['query'] as String,
      category: json['category'] as String?,
      totalCount: (json['total_count'] ?? json['totalCount']) as int,
      results: (json['results'] as List<dynamic>)
          .map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'category': category,
      'total_count': totalCount,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}
