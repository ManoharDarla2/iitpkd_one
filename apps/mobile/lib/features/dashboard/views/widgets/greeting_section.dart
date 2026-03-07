import 'package:flutter/material.dart';

/// The greeting section at the top of the dashboard.
///
/// When [userName] is provided (user logged in), shows "Hello, {name}".
/// When [userName] is null (not logged in), shows a formal time-of-day
/// greeting like "Good Morning" without any name.
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key, this.userName});

  /// The user's first name. Shows a formal time-based greeting if null.
  final String? userName;

  String _timeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = userName != null
        ? 'Hello, $userName'
        : _timeOfDayGreeting();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
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
