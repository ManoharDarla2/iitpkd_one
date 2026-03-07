import 'package:flutter/material.dart';

/// Horizontal day selector for the mess menu.
///
/// Shows Mon–Sun as selectable chips, highlighting the current selection.
class MessDaySelector extends StatelessWidget {
  const MessDaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  /// The selected day (lowercase, e.g. "monday").
  final String selectedDay;
  final ValueChanged<String> onDaySelected;

  static const _days = [
    ('Mon', 'monday'),
    ('Tue', 'tuesday'),
    ('Wed', 'wednesday'),
    ('Thu', 'thursday'),
    ('Fri', 'friday'),
    ('Sat', 'saturday'),
    ('Sun', 'sunday'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _days
            .map(
              (entry) => _DayChip(
                label: entry.$1,
                dayName: entry.$2,
                isSelected: selectedDay == entry.$2,
                onTap: () => onDaySelected(entry.$2),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.dayName,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String dayName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
