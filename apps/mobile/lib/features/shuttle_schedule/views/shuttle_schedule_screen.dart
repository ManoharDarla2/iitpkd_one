import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/features/schedule/view_models/schedule_shuttle_view_model.dart';
import 'package:csquare_connect/features/schedule/views/widgets/day_toggle.dart';
import 'package:csquare_connect/features/schedule/views/widgets/route_filter_chips.dart';
import 'package:csquare_connect/features/schedule/views/widgets/schedule_shuttle_card.dart';
import 'package:csquare_connect/routes/app_shell.dart';
import 'package:csquare_connect/shared/widgets/app_logo_title.dart';
import 'package:csquare_connect/shared/widgets/profile_avatar_action.dart';

class ShuttleScheduleScreen extends ConsumerStatefulWidget {
  const ShuttleScheduleScreen({super.key});

  @override
  ConsumerState<ShuttleScheduleScreen> createState() =>
      _ShuttleScheduleScreenState();
}

class _ShuttleScheduleScreenState extends ConsumerState<ShuttleScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final shuttleAsync = ref.watch(scheduleShuttleViewModelProvider);
    final viewModel = ref.read(scheduleShuttleViewModelProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomPadding = mainTabBottomPadding(context, extra: 10);

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle(title: 'Shuttle Schedule'),
        actions: const [ProfileAvatarAction()],
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshSchedules(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surfaceContainerLow,
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your travel day',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DateStrip(
                      selectedDate: _selectedDate,
                      horizontalPadding: 0,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                        viewModel.selectDate(date);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RouteFilterChips(
                  selected: viewModel.routeFilter,
                  onChanged: (route) => viewModel.selectRoute(route),
                ),
              ),
            ),
            shuttleAsync.when(
              data: (schedules) {
                final today = DateTime.now();
                final isToday = _isSameDay(_selectedDate, today);

                // Filter out past shuttles if viewing today
                final filteredSchedules = isToday
                    ? schedules.where((s) => s.isUpcoming).toList()
                    : [...schedules];

                if (filteredSchedules.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        isToday
                            ? 'No upcoming shuttles for today.'
                            : 'No shuttles scheduled for this day.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                final sorted = filteredSchedules
                  ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));
                return SliverList.builder(
                  itemCount: sorted.length + 1,
                  itemBuilder: (context, index) {
                    if (index == sorted.length) {
                      return SizedBox(height: bottomPadding);
                    }
                    return ScheduleShuttleCard(schedule: sorted[index]);
                  },
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
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: () => viewModel.refreshSchedules(),
                    child: const Text('Retry loading shuttles'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
