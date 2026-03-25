import 'package:flutter/material.dart';

/// Displays the initial empty state when no search has been performed,
/// or the "no results" state when a query returns zero matches.
///
/// In initial mode, shows a search icon and prompt text.
/// In "no results" mode, shows the query and a helpful message.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, this.query});

  /// If non-null and non-empty, shows the "no results" variant.
  /// If null, shows the initial "start searching" variant.
  final String? query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = query != null && query!.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off_rounded : Icons.manage_search_rounded,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No results for "$query"' : 'Search your campus',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try different keywords or check the spelling'
                  : 'Find equipment, people, labs, and schedules',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
