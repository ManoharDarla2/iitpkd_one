/// Categories available for filtering search results.
///
/// Each category maps to a distinct resource type in the Innovation Lab.
/// Excludes `projects` and `jobs` until the Collab feature and
/// backend support are ready.
enum SearchCategory {
  equipment('equipment', 'Equipment'),
  faculty('faculty', 'Faculty'),
  schedule('schedule', 'Schedule'),
  people('people', 'People'),
  labs('labs', 'Labs'),
  schedules('schedules', 'Schedules');

  const SearchCategory(this.value, this.label);

  /// The API query parameter value (e.g., `?category=facilities`).
  final String value;

  /// Human-readable label for display in filter chips.
  final String label;

  /// Parses a string value into a [SearchCategory], or returns null.
  static SearchCategory? fromValue(String? value) {
    if (value == null) return null;
    return SearchCategory.values.cast<SearchCategory?>().firstWhere(
      (c) => c!.value == value,
      orElse: () => null,
    );
  }
}
