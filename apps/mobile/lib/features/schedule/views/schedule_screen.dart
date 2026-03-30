import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum ScheduleEntryMode { shuttle, mess }

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({
    super.key,
    this.initialMode = ScheduleEntryMode.shuttle,
  });

  final ScheduleEntryMode initialMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Hub')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.9),
                  cs.secondaryContainer.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  initialMode == ScheduleEntryMode.mess
                      ? Icons.restaurant_menu_rounded
                      : Icons.directions_bus_filled_rounded,
                  color: cs.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    initialMode == ScheduleEntryMode.mess
                        ? 'Check today\'s meals and weekly menu quickly.'
                        : 'Track campus shuttles and the next departures.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ScheduleHubCard(
            icon: Icons.directions_bus_rounded,
            title: 'Shuttle Schedule',
            subtitle: 'Live departures and route filters',
            onTap: () => context.go('/schedule/shuttle'),
          ),
          const SizedBox(height: 12),
          _ScheduleHubCard(
            icon: Icons.restaurant_rounded,
            title: 'Mess Menu',
            subtitle: 'Meals by day with week toggle',
            onTap: () => context.go('/schedule/mess'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleHubCard extends StatelessWidget {
  const _ScheduleHubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
