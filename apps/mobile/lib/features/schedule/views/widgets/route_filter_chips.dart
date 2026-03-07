import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/schedule/data/repositories/schedule_shuttle_repository.dart';

/// Horizontal scrollable route filter chips for shuttle schedules.
///
/// Options: All Routes, Nila → Sahyadri, Sahyadri → Nila, Outside.
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
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Outside',
              icon: Icons.open_in_new_rounded,
              isSelected: selected == ShuttleRouteFilter.outside,
              useSecondaryColor: true,
              onTap: () => onChanged(ShuttleRouteFilter.outside),
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
    this.icon,
    this.useSecondaryColor = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool useSecondaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final activeColor =
        useSecondaryColor ? cs.secondary : cs.primary;
    final activeOnColor =
        useSecondaryColor ? cs.onSecondary : cs.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? activeOnColor : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? activeOnColor : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
