import 'package:flutter/material.dart';

/// A reusable section header with a title and an optional trailing action.
///
/// Used consistently across dashboard sections like
/// "Shuttle Tracker" and "Real-time Updates".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  /// The section title text (e.g., "Shuttle Tracker").
  final String title;

  /// Optional leading icon displayed before the title.
  final Widget? icon;

  /// Optional trailing widget (e.g., a "LIVE" badge or "History" link).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
