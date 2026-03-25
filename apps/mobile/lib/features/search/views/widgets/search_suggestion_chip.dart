import 'package:flutter/material.dart';

/// A tappable chip used for displaying search suggestions and recent queries.
///
/// Shows a leading icon (search for suggestions, history for recent)
/// and the text label. Taps trigger [onTap] to populate the search field.
class SearchSuggestionChip extends StatelessWidget {
  const SearchSuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isRecent = false,
    this.onDelete,
  });

  /// The suggestion text to display.
  final String label;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  /// Whether this is a recent search (shows history icon) or
  /// a popular suggestion (shows trending icon).
  final bool isRecent;

  /// If provided, shows a small delete button. Used for recent searches.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                isRecent ? Icons.history_rounded : Icons.trending_up_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              if (!isRecent)
                Icon(
                  Icons.north_west_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
