import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:csquare_connect/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:csquare_connect/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:csquare_connect/features/schedule/view_models/mess_view_model.dart';

class LiveUpdatesSection extends HookConsumerWidget {
  const LiveUpdatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _TabChip(
                label: 'Shuttle Live Board',
                isSelected: selectedIndex.value == 0,
                onTap: () => selectedIndex.value = 0,
              ),
              const SizedBox(width: 12),
              _TabChip(
                label: 'Today\'s Mess',
                isSelected: selectedIndex.value == 1,
                onTap: () => selectedIndex.value = 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: selectedIndex.value == 0
              ? const _ShuttleTabContent(key: ValueKey(0))
              : const _MessTabContent(key: ValueKey(1)),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ShuttleTabContent extends ConsumerWidget {
  const _ShuttleTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuttleAsync = ref.watch(shuttleViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return shuttleAsync.when(
      data: (schedules) {
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

        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: upcoming.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _ShuttleCard(bus: upcoming[index], isPrimary: index == 0);
            },
          ),
        );
      },
      loading: () => const _LoadingCard(message: 'Loading shuttle updates...'),
      error: (_, _) => _EmptyCard(
        message: 'Failed to load shuttle schedules.',
        actionLabel: 'Retry',
        onTap: () =>
            ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
      ),
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
          color: isPrimary ? cs.primaryContainer : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
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
              '${bus.from} -> ${bus.to}',
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

class _MessTabContent extends ConsumerWidget {
  const _MessTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(messViewModelProvider);

    return messAsync.when(
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

        final meals = [
          _MealInfo('Breakfast', '7:30-9:00 AM', mealDay.meals.breakfast),
          _MealInfo('Lunch', '12:00-2:00 PM', mealDay.meals.lunch),
          _MealInfo('Snacks', '4:30-5:30 PM', mealDay.meals.snacks),
          _MealInfo('Dinner', '7:30-9:00 PM', mealDay.meals.dinner),
        ];

        final activeIndex = _getActiveMealIndex();

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: meals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _MessCard(
                meal: meals[index],
                isActive: index == activeIndex,
              );
            },
          ),
        );
      },
      loading: () => const _LoadingCard(message: 'Loading mess menu...'),
      error: (_, _) =>
          const _EmptyCard(message: 'Unable to load menu at the moment.'),
    );
  }

  int _getActiveMealIndex() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 0;
    if (hour < 15) return 1;
    if (hour < 18) return 2;
    return 3;
  }
}

class _MealInfo {
  final String label;
  final String time;
  final List<String> items;
  _MealInfo(this.label, this.time, this.items);
}

class _MessCard extends StatelessWidget {
  const _MessCard({required this.meal, required this.isActive});

  final _MealInfo meal;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/schedules/mess'),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isActive ? cs.secondaryContainer : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  meal.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isActive ? cs.onSecondaryContainer : cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  meal.time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? cs.onSecondaryContainer.withValues(alpha: 0.8)
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: meal.items.isEmpty
                  ? Text(
                      'No items listed.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: meal.items.length > 3 ? 3 : meal.items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${meal.items[index]}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isActive
                                  ? cs.onSecondaryContainer
                                  : cs.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
            ),
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
