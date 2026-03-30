import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/day_toggle.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/mess_meal_card.dart';
import 'package:iitpkd_one/features/schedule/views/widgets/mess_week_toggle.dart';

class MessMenuScreen extends ConsumerStatefulWidget {
  const MessMenuScreen({super.key});

  @override
  ConsumerState<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends ConsumerState<MessMenuScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isCurrentWeek = true;

  @override
  Widget build(BuildContext context) {
    final messAsync = ref.watch(messViewModelProvider);
    final theme = Theme.of(context);

    final currentWeekType = MessViewModel.currentWeekType();
    final displayWeekType = _isCurrentWeek
        ? currentWeekType
        : (currentWeekType == 'odd' ? 'even' : 'odd');
    final selectedDayName = DateFormat(
      'EEEE',
    ).format(_selectedDate).toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Mess Menu')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(messViewModelProvider.notifier).refreshMenu(),
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
                  onDateSelected: (date) =>
                      setState(() => _selectedDate = date),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: MessWeekToggle(
                  isCurrentWeek: _isCurrentWeek,
                  onChanged: (value) => setState(() => _isCurrentWeek = value),
                ),
              ),
            ),
            messAsync.when(
              data: (menu) {
                final mealDay = menu.getMealsForDay(
                  displayWeekType,
                  selectedDayName,
                );
                if (mealDay == null) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No menu available for this day.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: MessMealCard(mealDay: mealDay),
                  ),
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
                    onPressed: () =>
                        ref.read(messViewModelProvider.notifier).refreshMenu(),
                    child: const Text('Retry loading menu'),
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
