import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:iitpkd_one/shared/widgets/section_header.dart';

/// The Shuttle Tracker section of the dashboard.
///
/// Shows one featured upcoming shuttle and two next upcoming shuttles.
class ShuttleTrackerSection extends ConsumerWidget {
  const ShuttleTrackerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuttleAsync = ref.watch(shuttleViewModelProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        SectionHeader(
          title: 'Shuttle Tracker',
          icon: Icon(
            Icons.directions_bus_filled_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),

        // Content
        shuttleAsync.when(
          data: (schedules) => _ShuttleContent(schedules: schedules),
          loading: () => const _ShuttleLoadingState(),
          error: (error, _) => _ShuttleErrorState(
            onRetry: () =>
                ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
          ),
        ),

        const SizedBox(height: 10),

        // See Full Schedule button
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: () {
              context.go('/schedules/shuttle');
            },
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text('See Full Schedule'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays one featured shuttle and two compact upcoming shuttles.
class _ShuttleContent extends StatelessWidget {
  const _ShuttleContent({required this.schedules});

  final List<ShuttleSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    final upcoming =
        schedules.where((s) => s.isUpcoming && !s.isOutsideTrip).toList()
          ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));

    final displaySchedules = upcoming.take(3).toList();

    if (displaySchedules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.8,
          ),
        ),
        child: Text(
          'No upcoming campus shuttle right now.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final primary = displaySchedules.first;
    final nextBuses = displaySchedules.skip(1).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.75),
            Theme.of(context).colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FeaturedBusCard(schedule: primary),
          if (nextBuses.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                'Next buses',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final bus in nextBuses) ...[
              _CompactBusCard(schedule: bus),
              if (bus != nextBuses.last) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

/// Loading skeleton for shuttle section.
class _ShuttleLoadingState extends StatelessWidget {
  const _ShuttleLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

/// Error state with retry button for shuttle section.
class _ShuttleErrorState extends StatelessWidget {
  const _ShuttleErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load shuttle schedules',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBusCard extends StatelessWidget {
  const _FeaturedBusCard({required this.schedule});

  final ShuttleSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final eta = schedule.minutesUntilDeparture;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Main Bus',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                schedule.time,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.from,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: cs.onSurfaceVariant),
              Expanded(
                child: Text(
                  schedule.to,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            eta > 0 ? 'Departs in $eta min' : 'Departing shortly',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactBusCard extends StatelessWidget {
  const _CompactBusCard({required this.schedule});

  final ShuttleSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${schedule.from} -> ${schedule.to}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            schedule.time,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
