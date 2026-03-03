import 'package:flutter/material.dart';

/// The mode options for the Schedule screen.
enum ScheduleMode { shuttle, messMenu }

/// A toggle between Shuttle and Mess Menu views.
///
/// Placed between the AppBar and content area as a [SegmentedButton].
class ScheduleModeSwitcher extends StatelessWidget {
  const ScheduleModeSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ScheduleMode selected;
  final ValueChanged<ScheduleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<ScheduleMode>(
          segments: const [
            ButtonSegment(
              value: ScheduleMode.shuttle,
              label: Text('Shuttle'),
              icon: Icon(Icons.directions_bus_rounded, size: 18),
            ),
            ButtonSegment(
              value: ScheduleMode.messMenu,
              label: Text('Mess Menu'),
              icon: Icon(Icons.restaurant_rounded, size: 18),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onChanged(selection.first),
          style: SegmentedButton.styleFrom(
            selectedForegroundColor: theme.colorScheme.onPrimary,
            selectedBackgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}
