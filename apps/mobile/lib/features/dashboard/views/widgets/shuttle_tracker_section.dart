import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/shuttle_item_tile.dart';
import 'package:iitpkd_one/shared/widgets/section_header.dart';

/// The Shuttle Tracker section of the dashboard.
///
/// Shows the next 2 upcoming shuttle departures with a "LIVE" indicator
/// and a "See Full Schedule" link button.
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
          )
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

        const SizedBox(height: 8),

        // See Full Schedule button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Navigate to full schedule screen
            },
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text('See Full Schedule'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays the top 2 upcoming shuttles in a card.
class _ShuttleContent extends StatelessWidget {
  const _ShuttleContent({required this.schedules});

  final List<ShuttleSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    // Get the next 2 upcoming departures
    final upcoming = schedules.where((s) => s.isUpcoming).toList()
      ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));

    final displaySchedules = upcoming.take(2).toList();

    if (displaySchedules.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No more shuttles scheduled for today.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < displaySchedules.length; i++) ...[
            ShuttleItemTile(schedule: displaySchedules[i], isNext: i == 0),
            if (i < displaySchedules.length - 1)
              Divider(
                height: 1,
                indent: 52,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
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
