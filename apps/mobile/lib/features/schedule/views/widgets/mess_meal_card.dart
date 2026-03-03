import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';

/// Displays a single day's mess menu with all four meal sections.
class MessMealCard extends StatelessWidget {
  const MessMealCard({super.key, required this.mealDay});

  final MealDay mealDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _MealSection(
            icon: Icons.free_breakfast_rounded,
            title: 'Breakfast',
            items: mealDay.meals.breakfast,
          ),
          const SizedBox(height: 12),
          _MealSection(
            icon: Icons.lunch_dining_rounded,
            title: 'Lunch',
            items: mealDay.meals.lunch,
          ),
          const SizedBox(height: 12),
          _MealSection(
            icon: Icons.cookie_rounded,
            title: 'Snacks',
            items: mealDay.meals.snacks,
          ),
          const SizedBox(height: 12),
          _MealSection(
            icon: Icons.dinner_dining_rounded,
            title: 'Dinner',
            items: mealDay.meals.dinner,
          ),
        ],
      ),
    );
  }
}

/// A single meal section (e.g., Breakfast) with icon, title, and food items.
class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.secondary, size: 22),
            ),
            const SizedBox(width: 12),

            // Title + items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: items
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            labelStyle: theme.textTheme.bodySmall,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
