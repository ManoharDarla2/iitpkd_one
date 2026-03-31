import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/quick_actions_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/shuttle_tracker_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/todays_mess_preview_section.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';
import 'package:iitpkd_one/shared/widgets/main_tab_app_bar.dart';

/// The main dashboard screen — the home tab of the app.
///
/// Uses [HookConsumerWidget] to combine flutter_hooks (for local UI state)
/// with Riverpod (for global state management).
///
/// Listens to shuttle and mess view models for error snackbars.
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shuttleAsync = ref.watch(shuttleViewModelProvider);
    final messAsync = ref.watch(messViewModelProvider);

    // Use a scroll controller hook for potential future use (e.g., pull-to-refresh)
    final scrollController = useScrollController();

    // Listen for errors and show snackbars
    ref.listen(shuttleViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load shuttle schedules');
      }
    });

    ref.listen(messViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load mess menu');
      }
    });

    return Scaffold(
      appBar: const MainTabAppBar(
        title: 'IITPKD One',
        subtitle: 'Campus pulse, one place',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both sections in parallel
          await Future.wait([
            ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
            ref.read(messViewModelProvider.notifier).refreshMenu(),
          ]);
        },
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeroCard(),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InsightCard(
                      title: 'Next Shuttle',
                      icon: Icons.directions_bus_filled_rounded,
                      value: _nextShuttleText(shuttleAsync),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InsightCard(
                      title: 'Current Meal',
                      icon: Icons.restaurant_rounded,
                      value: _currentMealText(messAsync),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const ShuttleTrackerSection(),

              SizedBox(height: 20),

              const TodaysMessPreviewSection(),

              SizedBox(height: 20),

              const QuickActionsSection(),

              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Pull down to refresh live shuttle and mess updates.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
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

  String _nextShuttleText(AsyncValue<List<ShuttleSchedule>> shuttleAsync) {
    return shuttleAsync.when(
      data: (schedules) {
        final upcoming =
            schedules.where((s) => s.isUpcoming && !s.isOutsideTrip).toList()
              ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));
        if (upcoming.isEmpty) return 'No upcoming trips';
        final next = upcoming.first;
        return '${next.time} · ${next.from}';
      },
      loading: () => 'Checking schedule...',
      error: (_, _) => 'Schedule unavailable',
    );
  }

  String _currentMealText(AsyncValue<dynamic> messAsync) {
    return messAsync.when(
      data: (_) {
        final hour = DateTime.now().hour;
        if (hour < 10) return 'Breakfast';
        if (hour < 15) return 'Lunch';
        if (hour < 18) return 'Snacks';
        return 'Dinner';
      },
      loading: () => 'Fetching menu...',
      error: (_, _) => 'Menu unavailable',
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.86),
            cs.secondaryContainer.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track shuttles, check meals, and jump into campus essentials quickly.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSecondaryContainer.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.icon,
    required this.value,
  });

  final String title;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
