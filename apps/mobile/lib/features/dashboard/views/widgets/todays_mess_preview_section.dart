import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';
import 'package:iitpkd_one/shared/widgets/section_header.dart';

class TodaysMessPreviewSection extends ConsumerWidget {
  const TodaysMessPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(messViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Today\'s Mess Menu',
          icon: Icon(
            Icons.restaurant_menu_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        messAsync.when(
          data: (menu) {
            final mealDay = menu.getMealsForDay(
              MessViewModel.currentWeekType(),
              DateFormat('EEEE').format(DateTime.now()).toLowerCase(),
            );
            if (mealDay == null) {
              return _EmptyMessCard(
                message: 'Menu is not available for today yet.',
              );
            }

            return _MealPreviewCard(mealDay: mealDay);
          },
          loading: () => const _LoadingMessCard(),
          error: (_, _) => const _EmptyMessCard(
            message: 'Unable to load menu at the moment.',
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push('/schedules/mess'),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Open Full Mess Menu'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MealPreviewCard extends StatelessWidget {
  const _MealPreviewCard({required this.mealDay});

  final MealDay mealDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slot = _activeSlot();
    final items = _slotItems(slot, mealDay);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                slot.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                slot.time,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No items listed for this meal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (final item in items.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  _MealSlot _activeSlot() {
    final hour = DateTime.now().hour;
    if (hour < 10) return const _MealSlot('Breakfast', '7:30 - 9:00 AM');
    if (hour < 15) return const _MealSlot('Lunch', '12:00 - 2:00 PM');
    if (hour < 18) return const _MealSlot('Snacks', '4:30 - 5:30 PM');
    return const _MealSlot('Dinner', '7:30 - 9:00 PM');
  }

  List<String> _slotItems(_MealSlot slot, MealDay mealDay) {
    switch (slot.label) {
      case 'Breakfast':
        return mealDay.meals.breakfast;
      case 'Lunch':
        return mealDay.meals.lunch;
      case 'Snacks':
        return mealDay.meals.snacks;
      default:
        return mealDay.meals.dinner;
    }
  }
}

class _LoadingMessCard extends StatelessWidget {
  const _LoadingMessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }
}

class _EmptyMessCard extends StatelessWidget {
  const _EmptyMessCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MealSlot {
  const _MealSlot(this.label, this.time);

  final String label;
  final String time;
}
