import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: schedule.isOutsideTrip
              ? cs.secondary.withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.5),
          width: schedule.isOutsideTrip ? 1 : 0.5,
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
              // Collapsed content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Time-first hierarchy + actions
                    Row(
                      children: [
                        _TimeChip(time: schedule.time),
                        if (schedule.isOutsideTrip) ...[
                          const SizedBox(width: 8),
                          const _OutsideBadge(),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: 32,
                          height: 32,
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
                              size: 18,
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
                    const SizedBox(height: 10),
                    // Row 2: Route summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    schedule.from,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    schedule.to,
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
              if (_isExpanded && schedule.via.isNotEmpty)
                _RouteStopsFlow(schedule: schedule),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final formatted = '${displayHour.toString().padLeft(2, '0')}:$minute';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: formatted,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
              TextSpan(
                text: ' $period',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Departure time',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.open_in_new_rounded,
            size: 11,
            color: cs.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Outside',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.secondary,
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route_rounded,
                  size: 15,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Route stops',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    final rowColor = isFirst
        ? cs.secondaryContainer.withValues(alpha: 0.24)
        : isLast
        ? cs.primaryContainer.withValues(alpha: 0.24)
        : cs.surface.withValues(alpha: 0.65);
    final dotColor = isFirst
        ? cs.secondary
        : isLast
        ? cs.primary
        : cs.onSurfaceVariant.withValues(alpha: 0.55);
    final labelText = isFirst
        ? 'Starting stop'
        : isLast
        ? 'Destination stop'
        : 'Via stop';
    final labelColor = isFirst
        ? cs.secondary
        : isLast
        ? cs.primary
        : cs.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: isEndpoint ? 9 : 7,
                height: isEndpoint ? 9 : 7,
                decoration: BoxDecoration(
                  color: isEndpoint ? dotColor : cs.surface,
                  border: Border.all(color: dotColor, width: 1.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: rowColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isEndpoint
                    ? labelColor.withValues(alpha: 0.28)
                    : cs.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isEndpoint ? FontWeight.w700 : FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      labelText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isOutsideTrip && isLast) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Outside route',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
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
      padding: const EdgeInsets.only(left: 7),
      child: Container(
        width: 1,
        height: 14,
        decoration: BoxDecoration(
          color: cs.outlineVariant.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
