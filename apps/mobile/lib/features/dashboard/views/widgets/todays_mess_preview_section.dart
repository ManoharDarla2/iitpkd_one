import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';

class TodaysMessPreviewSection extends ConsumerWidget {
  const TodaysMessPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messAsync = ref.watch(messViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIcon(icon: Icons.restaurant_rounded),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Today\'s Mess',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/schedules/mess'),
                child: const Text('Full Menu'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          messAsync.when(
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
              return _MealCard(mealDay: mealDay);
            },
            loading: () => const _LoadingCard(),
            error: (_, _) =>
                const _EmptyCard(message: 'Unable to load menu at the moment.'),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.mealDay});

  final MealDay mealDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final slot = _activeSlot();
    final items = _slotItems(slot.label, mealDay);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.secondaryContainer.withValues(alpha: 0.8),
            cs.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  slot.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(slot.time, style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 9),
          if (items.isEmpty)
            Text(
              'No items listed for this meal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            )
          else
            for (final item in items.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.primary,
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

  static _MealSlot _activeSlot() {
    final hour = DateTime.now().hour;
    if (hour < 10) return const _MealSlot('Breakfast', '7:30-9:00 AM');
    if (hour < 15) return const _MealSlot('Lunch', '12:00-2:00 PM');
    if (hour < 18) return const _MealSlot('Snacks', '4:30-5:30 PM');
    return const _MealSlot('Dinner', '7:30-9:00 PM');
  }

  static List<String> _slotItems(String slot, MealDay mealDay) {
    switch (slot) {
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: cs.onPrimaryContainer, size: 18),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          SizedBox(width: 10),
          Text('Loading mess menu...'),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
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
