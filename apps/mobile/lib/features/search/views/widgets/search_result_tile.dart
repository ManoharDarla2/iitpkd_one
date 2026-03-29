import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/search/data/models/search_category.dart';
import 'package:iitpkd_one/features/search/data/models/search_result_item.dart';

/// A card displaying a single search result.
///
/// Shows a category-colored leading icon or image, title, subtitle,
/// description, and a category badge. Equipment and People items
/// display their image when available. Taps trigger [onTap] for navigation.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.item, required this.onTap});

  final SearchResultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = item.imageUrl != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon or image thumbnail
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _categoryColor(
                      item.category,
                      theme,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              _categoryIcon(item.category),
                              size: 22,
                              color: _categoryColor(item.category, theme),
                            ),
                          ),
                        )
                      : Icon(
                          _categoryIcon(item.category),
                          size: 22,
                          color: _categoryColor(item.category, theme),
                        ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryBadge(category: item.category),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Subtitle
                      Text(
                        item.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description (if available)
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Chevron
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 10),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(SearchCategory category, ThemeData theme) {
    return switch (category) {
      SearchCategory.equipment => theme.colorScheme.tertiary,
      SearchCategory.faculty => theme.colorScheme.primary,
      SearchCategory.schedule => theme.colorScheme.secondary,
      SearchCategory.people => theme.colorScheme.primary,
      SearchCategory.labs => theme.colorScheme.secondary,
      SearchCategory.schedules => theme.colorScheme.secondary,
    };
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

/// Small colored badge showing the result's category.
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final SearchCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (category) {
      SearchCategory.equipment => theme.colorScheme.tertiary,
      SearchCategory.faculty => theme.colorScheme.primary,
      SearchCategory.schedule => theme.colorScheme.secondary,
      SearchCategory.people => theme.colorScheme.primary,
      SearchCategory.labs => theme.colorScheme.secondary,
      SearchCategory.schedules => theme.colorScheme.secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }
}
