import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';
import 'package:iitpkd_one/features/schedule/view_models/schedule_shuttle_view_model.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/day_toggle.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/mess_day_selector.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/mess_meal_card.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/mess_week_toggle.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/route_filter_chips.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/schedule_mode_switcher.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/schedule_shuttle_card.dart';

/// The main Schedule screen with Shuttle and Mess Menu modes.
///
/// Uses [HookConsumerWidget] for local UI state (hooks) and
/// Riverpod (for global state management).
class ScheduleScreen extends HookConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Local state: which mode is active
    final scheduleMode = useState(ScheduleMode.shuttle);

    // Local state for mess sub-view
    final isCurrentWeek = useState(true);
    final selectedMessDay = useState(MessViewModel.currentDayName());

    // Listen for shuttle errors
    ref.listen(scheduleShuttleViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load shuttle schedules');
      }
    });

    // Listen for mess errors
    ref.listen(messViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load mess menu');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IITPKD One',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open filter/settings panel
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filters',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                // TODO: Navigate to profile/login screen
              },
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode switcher (Shuttle ↔ Mess Menu)
          ScheduleModeSwitcher(
            selected: scheduleMode.value,
            onChanged: (mode) => scheduleMode.value = mode,
          ),

          // Content area
          Expanded(
            child: scheduleMode.value == ScheduleMode.shuttle
                ? _ShuttleSubView()
                : _MessSubView(
                    isCurrentWeek: isCurrentWeek,
                    selectedDay: selectedMessDay,
                  ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// =============================================================================
// Shuttle Sub-View
// =============================================================================

class _ShuttleSubView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuttleAsync = ref.watch(scheduleShuttleViewModelProvider);
    final viewModel = ref.read(scheduleShuttleViewModelProvider.notifier);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshSchedules(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Day toggle (Today / Tomorrow)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: DayToggle(
                isToday: viewModel.isToday,
                onChanged: (isToday) =>
                    viewModel.selectDay(isToday: isToday),
              ),
            ),
          ),

          // Route filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RouteFilterChips(
                selected: viewModel.routeFilter,
                onChanged: (route) => viewModel.selectRoute(route),
              ),
            ),
          ),

          // Shuttle cards
          shuttleAsync.when(
            data: (schedules) {
              if (schedules.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No shuttles scheduled for this selection.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort by departure time
              final sorted = [...schedules]
                ..sort(
                  (a, b) => a.todayDateTime.compareTo(b.todayDateTime),
                );

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == sorted.length) {
                      return const SizedBox(height: 24);
                    }
                    return ScheduleShuttleCard(schedule: sorted[index]);
                  },
                  childCount: sorted.length + 1, // +1 for bottom padding
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(
                message: 'Failed to load shuttle schedules',
                onRetry: () => viewModel.refreshSchedules(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Mess Sub-View
// =============================================================================

class _MessSubView extends ConsumerWidget {
  const _MessSubView({
    required this.isCurrentWeek,
    required this.selectedDay,
  });

  final ValueNotifier<bool> isCurrentWeek;
  final ValueNotifier<String> selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(messViewModelProvider);
    final theme = Theme.of(context);

    final currentWeekType = MessViewModel.currentWeekType();
    final displayWeekType = isCurrentWeek.value
        ? currentWeekType
        : (currentWeekType == 'odd' ? 'even' : 'odd');

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(messViewModelProvider.notifier).refreshMenu(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Week toggle (This Week / Next Week)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: MessWeekToggle(
                isCurrentWeek: isCurrentWeek.value,
                onChanged: (value) => isCurrentWeek.value = value,
              ),
            ),
          ),

          // Day selector (Mon–Sun)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MessDaySelector(
                selectedDay: selectedDay.value,
                onDaySelected: (day) => selectedDay.value = day,
              ),
            ),
          ),

          // Meal cards
          messAsync.when(
            data: (menu) {
              final mealDay = menu.getMealsForDay(
                displayWeekType,
                selectedDay.value,
              );

              if (mealDay == null) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No menu available for this day.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: MessMealCard(mealDay: mealDay),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(
                message: 'Failed to load mess menu',
                onRetry: () =>
                    ref.read(messViewModelProvider.notifier).refreshMenu(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Error State
// =============================================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
