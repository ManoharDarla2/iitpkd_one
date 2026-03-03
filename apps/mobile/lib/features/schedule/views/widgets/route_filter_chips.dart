import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/schedule/data/repositories/schedule_shuttle_repository.dart';

/// Horizontal scrollable route filter chips for shuttle schedules.
///
/// Options: All Routes, Nila → Sahyadri, Sahyadri → Nila.
class RouteFilterChips extends StatelessWidget {
  const RouteFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ShuttleRouteFilter selected;
  final ValueChanged<ShuttleRouteFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All Routes',
              isSelected: selected == ShuttleRouteFilter.all,
              onTap: () => onChanged(ShuttleRouteFilter.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Nila → Sahyadri',
              isSelected: selected == ShuttleRouteFilter.nilaToSahyadri,
              onTap: () => onChanged(ShuttleRouteFilter.nilaToSahyadri),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Sahyadri → Nila',
              isSelected: selected == ShuttleRouteFilter.sahyadriToNila,
              onTap: () => onChanged(ShuttleRouteFilter.sahyadriToNila),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
