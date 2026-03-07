import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';

/// Displays a single day's mess menu as a vertical timeline.
///
/// Each meal (Breakfast, Lunch, Snacks, Dinner) is a node in the timeline
/// with a time-of-day indicator, food items as clean text, and subtle color coding.
class MessMealCard extends StatelessWidget {
  const MessMealCard({super.key, required this.mealDay});

  final MealDay mealDay;

  @override
  Widget build(BuildContext context) {
    final meals = [
      _MealData(
        title: 'Breakfast',
        subtitle: '7:30 – 9:00 AM',
        icon: Icons.wb_sunny_rounded,
        items: mealDay.meals.breakfast,
        gradientIndex: 0,
      ),
      _MealData(
        title: 'Lunch',
        subtitle: '12:00 – 2:00 PM',
        icon: Icons.light_mode_rounded,
        items: mealDay.meals.lunch,
        gradientIndex: 1,
      ),
      _MealData(
        title: 'Snacks',
        subtitle: '4:30 – 5:30 PM',
        icon: Icons.coffee_rounded,
        items: mealDay.meals.snacks,
        gradientIndex: 2,
      ),
      _MealData(
        title: 'Dinner',
        subtitle: '7:30 – 9:00 PM',
        icon: Icons.dark_mode_rounded,
        items: mealDay.meals.dinner,
        gradientIndex: 3,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < meals.length; i++) ...[
            _MealTimelineNode(
              meal: meals[i],
              isFirst: i == 0,
              isLast: i == meals.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _MealData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;
  final int gradientIndex;

  const _MealData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    required this.gradientIndex,
  });
}

/// A single meal node in the vertical timeline.
class _MealTimelineNode extends StatelessWidget {
  const _MealTimelineNode({
    required this.meal,
    required this.isFirst,
    required this.isLast,
  });

  final _MealData meal;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Color palette for each meal slot
    final mealColors = [
      theme.colorScheme.secondary,          // Breakfast - warm orange
      theme.colorScheme.primary,            // Lunch - peacock green
      theme.colorScheme.tertiary,           // Snacks - purple-ish
      theme.colorScheme.primaryContainer,   // Dinner - deep teal
    ];
    final accentColor = mealColors[meal.gradientIndex];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Top connector
                if (!isFirst)
                  Expanded(
                    flex: 0,
                    child: Container(
                      width: 2,
                      height: 8,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                // Node circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(meal.icon, size: 16, color: accentColor),
                ),
                // Bottom connector
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Meal content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: title + time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          meal.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          meal.subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Food items as a clean formatted list
                    ...meal.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
