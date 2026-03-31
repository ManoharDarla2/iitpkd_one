import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iitpkd_one/shared/widgets/section_header.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Quick Actions',
          icon: Icon(
            Icons.bolt_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.school_rounded,
                title: 'Faculty',
                subtitle: 'Browse directory',
                onTap: () => context.push('/faculty'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Schedule',
                subtitle: 'Campus timings',
                onTap: () => context.go('/schedules/shuttle'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerLow,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
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
    );
  }
}
