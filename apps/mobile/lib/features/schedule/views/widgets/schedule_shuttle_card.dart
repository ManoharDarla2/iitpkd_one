import 'package:flutter/material.dart';
import 'package:csquare_connect/features/dashboard/data/models/shuttle_schedule.dart';

/// An expandable card displaying a single shuttle schedule entry.
class ScheduleShuttleCard extends StatefulWidget {
  const ScheduleShuttleCard({super.key, required this.schedule});

  final ShuttleSchedule schedule;

  @override
  State<ScheduleShuttleCard> createState() => _ScheduleShuttleCardState();
}

class _ScheduleShuttleCardState extends State<ScheduleShuttleCard> {
  bool _isExpanded = false;

  ShuttleSchedule get schedule => widget.schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: schedule.isOutsideTrip
              ? cs.secondary.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
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
              // Collapsed content
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Time-first hierarchy + actions
                    Row(
                      children: [
                        _TimeChip(time: schedule.time),
                        if (schedule.isOutsideTrip) ...[
                          const SizedBox(width: 6),
                          const _OutsideBadge(),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reminder set for ${schedule.from} -> ${schedule.to} at ${schedule.time}',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Set reminder',
                          ),
                        ),
                        if (schedule.via.isNotEmpty)
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Route summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    schedule.from,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    schedule.to,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

                // Expanded stop flow
                if (_isExpanded && schedule.via.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _RouteStopsFlow(schedule: schedule),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});

  final String time; // Example: "12:00 PM"

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Extract time and period
    final parts = time.trim().split(' ');
    final displayTime = parts[0];
    final period = parts.length > 1 ? parts[1] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: displayTime,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              if (period.isNotEmpty)
                TextSpan(
                  text: ' $period',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: period == 'PM'
                        ? cs.primary
                        : cs.tertiary,
                  ),
                ),
            ],
          ),
        ),
        Text(
          'Departure',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OutsideBadge extends StatelessWidget {
  const _OutsideBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: cs.secondary.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_in_new_rounded, size: 10, color: cs.secondary),
          const SizedBox(width: 3),
          Text(
            'Outside',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStopsFlow extends StatelessWidget {
  const _RouteStopsFlow({required this.schedule});

  final ShuttleSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final stops = [schedule.from, ...schedule.via, schedule.to];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route_rounded, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Route stops',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (int i = 0; i < stops.length; i++) ...[
              _FlowStopRow(
                name: stops[i],
                isFirst: i == 0,
                isLast: i == stops.length - 1,
                isOutsideTrip: schedule.isOutsideTrip,
              ),
              if (i < stops.length - 1) const _FlowConnector(),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlowStopRow extends StatelessWidget {
  const _FlowStopRow({
    required this.name,
    required this.isFirst,
    required this.isLast,
    required this.isOutsideTrip,
  });

  final String name;
  final bool isFirst;
  final bool isLast;
  final bool isOutsideTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEndpoint = isFirst || isLast;
    final dotColor = isFirst
        ? cs.secondary
        : isLast
        ? cs.primary
        : cs.onSurfaceVariant.withValues(alpha: 0.55);
    final labelText = isFirst
        ? 'Start'
        : isLast
        ? 'End'
        : 'Via';
    final labelColor = isFirst
        ? cs.secondary
        : isLast
        ? cs.primary
        : cs.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 14,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Container(
                width: isEndpoint ? 8 : 6,
                height: isEndpoint ? 8 : 6,
                decoration: BoxDecoration(
                  color: isEndpoint ? dotColor : cs.surface,
                  border: Border.all(color: dotColor, width: 1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isEndpoint ? FontWeight.w600 : FontWeight.w400,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  labelText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FlowConnector extends StatelessWidget {
  const _FlowConnector();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        width: 1,
        height: 10,
        color: cs.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
