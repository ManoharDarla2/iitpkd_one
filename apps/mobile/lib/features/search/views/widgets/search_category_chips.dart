import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/search/data/models/search_category.dart';

/// Horizontal scrollable category filter chips for search.
///
/// Shows "All" plus one chip per [SearchCategory]. Uses the app's
/// secondary color scheme for the selected state, matching the
/// department filter chip pattern from the Faculty screen.
class SearchCategoryChips extends StatelessWidget {
  const SearchCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Currently selected category (null = All).
  final SearchCategory? selected;

  /// Called when a category is tapped (null = All).
  final ValueChanged<SearchCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              selectedColor: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.3,
              ),
              checkmarkColor: theme.colorScheme.secondary,
              labelStyle: TextStyle(
                color: selected == null
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          // Category chips
          ...SearchCategory.values.map((category) {
            final isSelected = selected == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  _categoryIcon(category),
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(category.label),
                selected: isSelected,
                onSelected: (_) => onSelected(isSelected ? null : category),
                selectedColor: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.3,
                ),
                checkmarkColor: theme.colorScheme.secondary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _categoryIcon(SearchCategory category) {
    return switch (category) {
      SearchCategory.equipment => Icons.build_rounded,
      SearchCategory.people => Icons.person_rounded,
      SearchCategory.labs => Icons.science_rounded,
      SearchCategory.schedules => Icons.schedule_rounded,
    };
  }
}
