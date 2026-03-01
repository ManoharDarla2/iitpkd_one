import 'package:flutter/material.dart';

/// The greeting section at the top of the dashboard.
///
/// Displays "Hello, {name}" and a contextual subtitle.
/// When login is implemented, [userName] will come from the auth state.
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key, this.userName});

  /// The user's first name. Shows "Hello, Guest" if null.
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = userName ?? 'Guest';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $displayName',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what's happening on campus today.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
