import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:csquare_connect/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:csquare_connect/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:csquare_connect/features/schedule/view_models/mess_view_model.dart';

/// Live Campus Status section with shuttle horizontal cards and current meal.
class LiveUpdatesSection extends ConsumerWidget {
  const LiveUpdatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShuttleSection(),
        const SizedBox(height: 20),
        _MessSection(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ShuttleSection extends ConsumerWidget {
  const _ShuttleSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuttleAsync = ref.watch(shuttleViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  "On-Campus Shuttle",
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/schedules/shuttle'),
                child: const Text('View Full Schedule'),
              ),
            ),
          ],
        ),

        shuttleAsync.when(
          data: (schedules) {
            // Get all upcoming shuttles (model now handles 12 AM as today's last bus)
            final upcoming =
                schedules
                    .where((item) => item.isUpcoming && !item.isOutsideTrip)
                    .toList()
                  ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));

            if (upcoming.isEmpty) {
              return _EmptyCard(
                message: 'No upcoming campus shuttle right now.',
                actionLabel: 'Open Full Schedule',
                onTap: () => context.go('/schedules/shuttle'),
              );
            }

            // Check if next shuttle is >= 1hr 10min (70 min) away
            final nextBusMinutes = upcoming.first.minutesUntilDeparture;
            if (nextBusMinutes >= 70) {
              return _EmptyCard(
                message: 'Next shuttle is more than an hour away.',
                actionLabel: 'View Full Schedule',
                onTap: () => context.go('/schedules/shuttle'),
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: upcoming.length > 3 ? 3 : upcoming.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _ShuttleCard(
                    bus: upcoming[index],
                    isPrimary: index == 0,
                  );
                },
              ),
            );
          },
          loading: () =>
              const _LoadingCard(message: 'Loading shuttle updates...'),
          error: (_, _) => _EmptyCard(
            message: 'Failed to load shuttle schedules.',
            actionLabel: 'Retry',
            onTap: () =>
                ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
          ),
        ),
      ],
    );
  }
}

class _ShuttleCard extends StatelessWidget {
  const _ShuttleCard({required this.bus, required this.isPrimary});

  final ShuttleSchedule bus;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.go('/schedules/shuttle'),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isPrimary
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPrimary ? cs.primary : cs.outline.withValues(alpha: 0.15),
            width: 1.5,
          ),
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
                    color: isPrimary
                        ? cs.primary.withValues(alpha: 0.15)
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    bus.minutesUntilDeparture > 0
                        ? 'In ${bus.minutesUntilDeparture} min'
                        : 'Departing now',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isPrimary ? cs.primary : cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.directions_bus_rounded,
                  size: 18,
                  color: isPrimary ? cs.primary : cs.onSurfaceVariant,
                ),
              ],
            ),
            const Spacer(),
            Text(
              bus.time,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isPrimary ? cs.onPrimaryContainer : cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${bus.from} → ${bus.to}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? cs.onPrimaryContainer.withValues(alpha: 0.8)
                    : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessSection extends ConsumerWidget {
  const _MessSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(messViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              "Today's Mess",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        messAsync.when(
          data: (menu) {
            final mealDay = menu.getMealsForDay(
              MessViewModel.currentWeekType(),
              DateFormat('EEEE').format(DateTime.now()).toLowerCase(),
            );

            if (mealDay == null) {
              return const _EmptyCard(
                message: 'Menu is not available for today yet.',
              );
            }

            final hour = DateTime.now().hour;
            String label, time;
            List<String> items;

            if (hour < 10) {
              label = 'Breakfast';
              time = '7:30-9:00 AM';
              items = mealDay.meals.breakfast;
            } else if (hour < 15) {
              label = 'Lunch';
              time = '12:00-2:00 PM';
              items = mealDay.meals.lunch;
            } else if (hour < 18) {
              label = 'Snacks';
              time = '4:30-5:30 PM';
              items = mealDay.meals.snacks;
            } else {
              label = 'Dinner';
              time = '7:30-9:00 PM';
              items = mealDay.meals.dinner;
            }

            return _CurrentMealCard(label: label, time: time, items: items);
          },
          loading: () => const _LoadingCard(message: 'Loading mess menu...'),
          error: (_, _) =>
              const _EmptyCard(message: 'Unable to load menu at the moment.'),
        ),
      ],
    );
  }
}

class _CurrentMealCard extends StatelessWidget {
  const _CurrentMealCard({
    required this.label,
    required this.time,
    required this.items,
  });

  final String label;
  final String time;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/schedules/mess'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSecondaryContainer.withValues(alpha: 0.6),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...items
                  .take(4)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSecondaryContainer,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (items.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'and ${items.length - 4} more items...',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSecondaryContainer.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'No items listed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSecondaryContainer.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          const SizedBox(width: 14),
          Text(message),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message, this.actionLabel, this.onTap});

  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
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
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
