import 'package:iitpkd_one/features/search/data/models/search_category.dart';

/// A single item returned from the search API.
///
/// Uses a unified shape across all categories so the UI can render
/// a consistent card regardless of whether the result is a facility,
/// person, lab, or schedule entry. Category-specific data lives in
/// the [metadata] map.
class SearchResultItem {
  final String id;
  final SearchCategory category;
  final String title;
  final String subtitle;
  final String? description;
  final String? imageUrl;
  final Map<String, String> metadata;

  const SearchResultItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    this.description,
    this.imageUrl,
    this.metadata = const {},
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] as String,
      category:
          SearchCategory.fromValue(json['category'] as String) ??
          SearchCategory.equipment,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.value,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }
}
