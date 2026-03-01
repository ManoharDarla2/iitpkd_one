import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';

/// A card displaying a single notice/update.
///
/// Features:
/// - Colored left border based on importance (red for critical, grey for normal)
/// - Icon and importance badge
/// - Action buttons ("Add to Calendar", "Dismiss")
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    this.onDismiss,
    this.onAddToCalendar,
    this.postedTimeAgo,
  });

  /// The notice data to display.
  final Notice notice;

  /// Called when the user taps "Dismiss".
  final VoidCallback? onDismiss;

  /// Called when the user taps "Add to Calendar".
  final VoidCallback? onAddToCalendar;

  /// Display string for how long ago the notice was posted (e.g., "15m ago").
  final String? postedTimeAgo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCritical = notice.isCritical;

    final borderColor = isCritical
        ? theme.colorScheme.error
        : theme.colorScheme.outlineVariant;

    final cardColor = isCritical
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.15)
        : theme.colorScheme.surfaceContainerLowest;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Colored left accent strip
                Container(
                  width: 3,
                  decoration: BoxDecoration(color: borderColor),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: icon + title + badge/time
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category icon
                            _CategoryIcon(
                              category: notice.category,
                              isCritical: isCritical,
                            ),
                            const SizedBox(width: 12),

                            // Title and content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title row with badge
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notice.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isCritical)
                                        _ImportanceBadge()
                                      else if (postedTimeAgo != null)
                                        Text(
                                          postedTimeAgo!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Description
                                  Text(
                                    notice.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),

                                  // Posted time for critical notices
                                  if (isCritical && postedTimeAgo != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Posted $postedTimeAgo',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                  ],

                                  // Action buttons for non-critical notices
                                  if (!isCritical &&
                                      (onAddToCalendar != null ||
                                          onDismiss != null)) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (onAddToCalendar != null)
                                          FilledButton.tonal(
                                            onPressed: onAddToCalendar,
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              textStyle:
                                                  theme.textTheme.labelMedium,
                                            ),
                                            child: const Text(
                                              'Add to Calendar',
                                            ),
                                          ),
                                        if (onAddToCalendar != null &&
                                            onDismiss != null)
                                          const SizedBox(width: 8),
                                        if (onDismiss != null)
                                          OutlinedButton(
                                            onPressed: onDismiss,
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              textStyle:
                                                  theme.textTheme.labelMedium,
                                            ),
                                            child: const Text('Dismiss'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon representing the notice category.
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category, required this.isCritical});

  final String category;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final IconData icon;
    final Color iconColor;
    final Color bgColor;

    if (isCritical) {
      icon = Icons.warning_rounded;
      iconColor = theme.colorScheme.error;
      bgColor = theme.colorScheme.errorContainer.withValues(alpha: 0.4);
    } else {
      switch (category) {
        case 'academic':
        case 'research':
          icon = Icons.campaign_rounded;
          iconColor = theme.colorScheme.primary;
          bgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.4);
        case 'event':
          icon = Icons.event_rounded;
          iconColor = theme.colorScheme.secondary;
          bgColor = theme.colorScheme.secondaryContainer.withValues(alpha: 0.4);
        case 'facility':
          icon = Icons.build_rounded;
          iconColor = theme.colorScheme.tertiary;
          bgColor = theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4);
        default:
          icon = Icons.info_outline_rounded;
          iconColor = theme.colorScheme.onSurfaceVariant;
          bgColor = theme.colorScheme.surfaceContainerHighest;
      }
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

/// Red "IMPORTANT" badge for critical notices.
class _ImportanceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'IMPORTANT',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
