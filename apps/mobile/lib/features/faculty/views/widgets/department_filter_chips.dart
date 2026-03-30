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
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _DeptChip(
              label: 'All',
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
          ),
          // Department chips
          ...departments.map((dept) {
            final isSelected = selected == dept;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DeptChip(
                label: _abbreviate(dept),
                isSelected: isSelected,
                onTap: () => onSelected(dept),
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

class _DeptChip extends StatelessWidget {
  const _DeptChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.secondaryContainer : cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? cs.secondary.withValues(alpha: 0.4)
                : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? cs.secondary : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
