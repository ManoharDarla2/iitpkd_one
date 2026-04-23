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
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ModernFilterChip(
              label: 'All',
              icon: Icons.apps_rounded,
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
          ),
          // Category chips
          ...SearchCategory.values.map((category) {
            final isSelected = selected == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ModernFilterChip(
                label: category.label,
                icon: _categoryIcon(category),
                isSelected: isSelected,
                onTap: () => onSelected(isSelected ? null : category),
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
      SearchCategory.faculty => Icons.person_rounded,
      SearchCategory.schedule => Icons.schedule_rounded,
      SearchCategory.people => Icons.person_rounded,
      SearchCategory.labs => Icons.science_rounded,
      SearchCategory.schedules => Icons.schedule_rounded,
    };
  }
}

class _ModernFilterChip extends StatelessWidget {
  const _ModernFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.35)
                : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
