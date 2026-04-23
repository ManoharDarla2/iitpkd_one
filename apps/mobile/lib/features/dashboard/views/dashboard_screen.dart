import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/quick_actions_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/shuttle_tracker_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/todays_mess_preview_section.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';
import 'package:iitpkd_one/routes/app_shell.dart';
import 'package:iitpkd_one/shared/widgets/main_tab_app_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuttleAsync = ref.watch(shuttleViewModelProvider);
    ref.watch(messViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
        subtitle: 'Your campus control center',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surface, cs.surfaceContainerLowest, cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
              ref.read(messViewModelProvider.notifier).refreshMenu(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  mainTabBottomPadding(context, extra: 6),
                ),
                sliver: SliverList.list(
                  children: [
                    _HeroPanel(
                      nextShuttle: _nextShuttleLabel(shuttleAsync),
                      activeMeal: _activeMealLabel(),
                    ),
                    const SizedBox(height: 12),
                    const ShuttleTrackerSection(),
                    const SizedBox(height: 12),
                    const TodaysMessPreviewSection(),
                    const SizedBox(height: 12),
                    const QuickActionsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _nextShuttleLabel(
    AsyncValue<List<ShuttleSchedule>> shuttleAsync,
  ) {
    return shuttleAsync.when(
      data: (schedules) {
        final upcoming =
            schedules
                .where((item) => item.isUpcoming && !item.isOutsideTrip)
                .toList()
              ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));
        if (upcoming.isEmpty) {
          return 'No upcoming trips';
        }
        final next = upcoming.first;
        return '${next.time} ${next.from}';
      },
      loading: () => 'Updating...',
      error: (_, _) => 'Unavailable',
    );
  }

  static String _activeMealLabel() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Breakfast';
    if (hour < 15) return 'Lunch';
    if (hour < 18) return 'Snacks';
    return 'Dinner';
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.nextShuttle, required this.activeMeal});

  final String nextShuttle;
  final String activeMeal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.94),
            cs.tertiary.withValues(alpha: 0.86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$greeting.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Everything you need for campus movement and meals, in one place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  icon: Icons.directions_bus_rounded,
                  title: 'Next Shuttle',
                  value: nextShuttle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.restaurant_rounded,
                  title: 'Current Meal',
                  value: activeMeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onPrimary),
          const SizedBox(height: 7),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}