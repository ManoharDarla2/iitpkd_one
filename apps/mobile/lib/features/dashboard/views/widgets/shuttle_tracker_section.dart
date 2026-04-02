import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/view_models/shuttle_view_model.dart';

class ShuttleTrackerSection extends ConsumerWidget {
  const ShuttleTrackerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuttleAsync = ref.watch(shuttleViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIcon(icon: Icons.route_rounded),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shuttle Live Board',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/schedules/shuttle'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          shuttleAsync.when(
            data: (schedules) => _ShuttleContent(schedules: schedules),
            loading: () => const _LoadingState(),
            error: (_, _) => _ErrorState(
              onRetry: () {
                ref.read(shuttleViewModelProvider.notifier).refreshSchedules();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShuttleContent extends StatelessWidget {
  const _ShuttleContent({required this.schedules});

  final List<ShuttleSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final upcoming =
        schedules
            .where((item) => item.isUpcoming && !item.isOutsideTrip)
            .toList()
          ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));

    if (upcoming.isEmpty) {
      return _EmptyState(
        message: 'No upcoming campus shuttle right now.',
        actionLabel: 'Open Full Schedule',
        onTap: () => context.go('/schedules/shuttle'),
      );
    }

    final primary = upcoming.first;
    final secondary = upcoming.skip(1).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.85),
                cs.surfaceContainerLow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TagChip(
                    text: primary.minutesUntilDeparture > 0
                        ? 'In ${primary.minutesUntilDeparture} min'
                        : 'Departing now',
                  ),
                  const Spacer(),
                  Text(
                    primary.time,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${primary.from} -> ${primary.to}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (primary.via.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Via ${primary.via.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Next departures',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final bus in secondary)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${bus.from} -> ${bus.to}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bus.time,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: cs.onPrimaryContainer, size: 18),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          SizedBox(width: 10),
          Text('Loading shuttle updates...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      message: 'Failed to load shuttle schedules.',
      actionLabel: 'Retry',
      onTap: onRetry,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
