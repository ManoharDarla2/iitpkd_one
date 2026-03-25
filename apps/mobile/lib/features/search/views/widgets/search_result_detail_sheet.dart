import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/search/data/models/search_category.dart';
import 'package:iitpkd_one/features/search/data/models/search_result_item.dart';

/// Bottom sheet that displays detailed information about a search result.
///
/// Used for equipment, labs, and schedule items (People results navigate
/// to the FacultyDetailScreen instead of showing this sheet).
/// Equipment items display their image when available.
class SearchResultDetailSheet extends StatelessWidget {
  const SearchResultDetailSheet({super.key, required this.item});

  final SearchResultItem item;

  /// Shows this sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, SearchResultItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SearchResultDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hero image (if available)
              if (item.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: _categoryColor(theme).withValues(alpha: 0.1),
                        child: Icon(
                          _categoryIcon(),
                          size: 48,
                          color: _categoryColor(theme),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Icon + title row
              Row(
                children: [
                  if (item.imageUrl == null) ...[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _categoryColor(theme).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _categoryIcon(),
                        size: 24,
                        color: _categoryColor(theme),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  item.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],

              // Metadata entries
              if (item.metadata.isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...item.metadata.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            _formatKey(entry.key),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _categoryColor(ThemeData theme) {
    return switch (item.category) {
      SearchCategory.equipment => theme.colorScheme.tertiary,
      SearchCategory.people => theme.colorScheme.primary,
      SearchCategory.labs => theme.colorScheme.secondary,
      SearchCategory.schedules => theme.colorScheme.primary,
    };
  }

  IconData _categoryIcon() {
    return switch (item.category) {
      SearchCategory.equipment => Icons.build_rounded,
      SearchCategory.people => Icons.person_rounded,
      SearchCategory.labs => Icons.science_rounded,
      SearchCategory.schedules => Icons.schedule_rounded,
    };
  }

  /// Converts snake_case keys to Title Case for display.
  String _formatKey(String key) {
    return key
        .split('_')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }
}
