import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';

/// An expandable card displaying a single shuttle schedule entry.
///
/// Collapsed: From → To route with departure time and notification bell.
/// Expanded: Vertical timeline showing all via stops from origin to destination.
class ScheduleShuttleCard extends StatefulWidget {
  const ScheduleShuttleCard({super.key, required this.schedule});

  final ShuttleSchedule schedule;

  @override
  State<ScheduleShuttleCard> createState() => _ScheduleShuttleCardState();
}

class _ScheduleShuttleCardState extends State<ScheduleShuttleCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  ShuttleSchedule get schedule => widget.schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: schedule.via.isNotEmpty
            ? () => setState(() => _isExpanded = !_isExpanded)
            : null,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              // Main content (always visible)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                child: Row(
                  children: [
                    // Bus icon with time badge
                    _DepartureTimeBadge(time: _formatTime(schedule.time)),
                    const SizedBox(width: 16),

                    // Route info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // From → To
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  schedule.from,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
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
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Stop count + outside trip indicator
                          Row(
                            children: [
                              if (schedule.via.isNotEmpty) ...[
                                Icon(
                                  Icons.linear_scale_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule.via.length} stop${schedule.via.length > 1 ? 's' : ''}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (schedule.isOutsideTrip) ...[
                                if (schedule.via.isNotEmpty)
                                  const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Outside',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Trailing: bell + expand chevron
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Reminder set for ${schedule.from} → ${schedule.to} at ${schedule.time}',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            size: 22,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Set reminder',
                        ),
                        if (schedule.via.isNotEmpty)
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Expandable via-stops timeline
              if (_isExpanded && schedule.via.isNotEmpty)
                _ViaStopsTimeline(schedule: schedule),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute\n$period';
  }
}

/// Departure time shown as a compact vertical badge.
class _DepartureTimeBadge extends StatelessWidget {
  const _DepartureTimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = time.split('\n');

    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            parts[0], // "09:00"
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            parts.length > 1 ? parts[1] : '', // "AM"
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical timeline showing the full route: from → via stops → to.
class _ViaStopsTimeline extends StatelessWidget {
  const _ViaStopsTimeline({required this.schedule});

  final ShuttleSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build the full stop list: origin + via stops + destination
    final stops = [schedule.from, ...schedule.via, schedule.to];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            for (int i = 0; i < stops.length; i++) ...[
              _StopNode(
                name: stops[i],
                isFirst: i == 0,
                isLast: i == stops.length - 1,
              ),
              if (i < stops.length - 1) _ConnectorLine(),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single stop in the timeline.
class _StopNode extends StatelessWidget {
  const _StopNode({
    required this.name,
    required this.isFirst,
    required this.isLast,
  });

  final String name;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEndpoint = isFirst || isLast;

    return Row(
      children: [
        // Circle indicator
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color:
                isEndpoint ? theme.colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: isEndpoint
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              width: isEndpoint ? 0 : 1.5,
            ),
            shape: BoxShape.circle,
          ),
          child: !isEndpoint
              ? Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        // Stop name
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isEndpoint ? FontWeight.w600 : FontWeight.w400,
              color: isEndpoint
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Label for origin/destination
        if (isFirst)
          Text(
            'Start',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (isLast)
          Text(
            'End',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

/// Dashed-style vertical connector between stops.
class _ConnectorLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: SizedBox(
        height: 20,
        child: VerticalDivider(
          width: 2,
          thickness: 1.5,
          color: theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
