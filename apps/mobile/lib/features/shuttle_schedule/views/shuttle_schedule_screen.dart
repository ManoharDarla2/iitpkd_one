import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/schedule/view_models/schedule_shuttle_view_model.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/day_toggle.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/route_filter_chips.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/schedule_shuttle_card.dart';
import 'package:iitpkd_one/shared/widgets/main_tab_app_bar.dart';

class ShuttleScheduleScreen extends ConsumerStatefulWidget {
  const ShuttleScheduleScreen({super.key});

  @override
  ConsumerState<ShuttleScheduleScreen> createState() =>
      _ShuttleScheduleScreenState();
}

class _ShuttleScheduleScreenState extends ConsumerState<ShuttleScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final shuttleAsync = ref.watch(scheduleShuttleViewModelProvider);
    final viewModel = ref.read(scheduleShuttleViewModelProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: const MainTabAppBar(
        title: 'Shuttle Schedule',
        subtitle: 'Live by route and day',
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
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      cs.primaryContainer.withValues(alpha: 0.7),
                      cs.surfaceContainerLow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your travel day',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
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
                if (schedules.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No shuttles scheduled for this day.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                final sorted = [...schedules]
                  ..sort((a, b) => a.todayDateTime.compareTo(b.todayDateTime));
                return SliverList.builder(
                  itemCount: sorted.length + 1,
                  itemBuilder: (context, index) {
                    if (index == sorted.length) {
                      return const SizedBox(height: 20);
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
