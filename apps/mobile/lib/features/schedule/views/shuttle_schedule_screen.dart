import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/schedule/view_models/schedule_shuttle_view_model.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/day_toggle.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/route_filter_chips.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/schedule_shuttle_card.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Shuttle Schedule')),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshSchedules(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: theme.colorScheme.surfaceContainerLow,
                ),
                child: DateStrip(
                  selectedDate: _selectedDate,
                  horizontalPadding: 0,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = date);
                    viewModel.selectDate(date);
                  },
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
                          color: theme.colorScheme.onSurfaceVariant,
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
                child: Center(child: CircularProgressIndicator()),
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
