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
    final cs = theme.colorScheme;

    final currentWeekType = MessViewModel.currentWeekType();
    final displayWeekType = _isCurrentWeek
        ? currentWeekType
        : (currentWeekType == 'odd' ? 'even' : 'odd');
    final selectedDayName = DateFormat(
      'EEEE',
    ).format(_selectedDate).toLowerCase();
    final selectedDateLabel = DateFormat('EEE, d MMM').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Menu'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(messViewModelProvider.notifier).refreshMenu(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      cs.secondaryContainer.withValues(alpha: 0.72),
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
                      'Plan meals for $selectedDateLabel',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DateStrip(
                      selectedDate: _selectedDate,
                      horizontalPadding: 0,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ],
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
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'No menu available for this day.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      children: [
                        _SelectedDayPill(
                          weekType: displayWeekType,
                          dayName: selectedDayName,
                        ),
                        const SizedBox(height: 10),
                        MessMealCard(mealDay: mealDay),
                      ],
                    ),
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

class _SelectedDayPill extends StatelessWidget {
  const _SelectedDayPill({required this.weekType, required this.dayName});

  final String weekType;
  final String dayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${dayName[0].toUpperCase()}${dayName.substring(1)} · ${weekType[0].toUpperCase()}${weekType.substring(1)} week',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
