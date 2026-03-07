import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';

/// A single shuttle schedule tile showing route, time, and countdown.
///
/// Displays:
/// - From -> To with arrow
/// - "Next Departure" or "Scheduled" status
/// - Time badge with minutes until departure
class ShuttleItemTile extends StatelessWidget {
  const ShuttleItemTile({
    super.key,
    required this.schedule,
    this.isNext = false,
  });

  /// The shuttle schedule to display.
  final ShuttleSchedule schedule;

  /// Whether this is the next upcoming shuttle (uses bus icon vs clock).
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = schedule.minutesUntilDeparture;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Leading icon
          Icon(
            isNext ? Icons.directions_bus_rounded : Icons.schedule_rounded,
            color: isNext
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Route info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From -> To
                Row(
                  children: [
                    Text(
                      schedule.from,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        schedule.to,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Status + time
                Text(
                  isNext
                      ? 'Next Departure \u2022 ${schedule.time} AM'
                      : 'Scheduled \u2022 ${schedule.time} AM',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Countdown badge
          if (minutes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isNext
                    ? theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.4,
                      )
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$minutes min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isNext
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
