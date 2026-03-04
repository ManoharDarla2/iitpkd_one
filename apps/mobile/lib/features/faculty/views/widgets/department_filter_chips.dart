import 'package:flutter/material.dart';

/// Horizontal scrollable department filter chips.
///
/// Shows "All" plus one chip per department. Uses the app's
/// secondary color for the selected state to match branding.
class DepartmentFilterChips extends StatelessWidget {
  const DepartmentFilterChips({
    super.key,
    required this.departments,
    required this.selected,
    required this.onSelected,
  });

  /// List of department names to display as chips.
  final List<String> departments;

  /// Currently selected department (null = All).
  final String? selected;

  /// Called when a department is selected (null = All).
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              selectedColor: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.3,
              ),
              checkmarkColor: theme.colorScheme.secondary,
              labelStyle: TextStyle(
                color: selected == null
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          // Department chips
          ...departments.map((dept) {
            final isSelected = selected == dept;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_abbreviate(dept)),
                selected: isSelected,
                onSelected: (_) => onSelected(dept),
                selectedColor: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.3,
                ),
                checkmarkColor: theme.colorScheme.secondary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _abbreviate(String dept) {
    const abbreviations = {
      'Computer Science and Engineering': 'CSE',
      'Electrical Engineering': 'EE',
      'Mechanical Engineering': 'ME',
      'Humanities and Social Sciences': 'HSS',
    };
    return abbreviations[dept] ?? dept;
  }
}
