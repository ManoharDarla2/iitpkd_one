import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A horizontal scrollable date strip showing 7 days.
///
/// Displays dates as simple cards with today highlighted.
/// Users can tap any day to select it. Shared between shuttle and mess views.
class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.horizontalPadding = 16,
    this.height = 72,
  });

  /// The currently selected date.
  final DateTime selectedDate;

  /// Called when the user taps a date.
  final ValueChanged<DateTime> onDateSelected;

  final double horizontalPadding;

  final double height;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    // Generate 7 days starting from today
    final dates = List.generate(7, (i) => startOfToday.add(Duration(days: i)));

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, startOfToday);

          return _DateCard(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayAbbr = DateFormat('EEE').format(date);
    final dayNum = date.day.toString();

    final bgColor = isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHigh;
    final textColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayAbbr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dayNum,
              style: theme.textTheme.titleSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
