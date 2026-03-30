import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/greeting_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/quick_actions_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/shuttle_tracker_section.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/todays_mess_preview_section.dart';
import 'package:iitpkd_one/features/schedule/view_models/mess_view_model.dart';

/// The main dashboard screen — the home tab of the app.
///
/// Uses [HookConsumerWidget] to combine flutter_hooks (for local UI state)
/// with Riverpod (for global state management).
///
/// Listens to shuttle and mess view models for error snackbars.
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Use a scroll controller hook for potential future use (e.g., pull-to-refresh)
    final scrollController = useScrollController();

    // Listen for errors and show snackbars
    ref.listen(shuttleViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load shuttle schedules');
      }
    });

    ref.listen(messViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load mess menu');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IITPKD One',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open filter/settings panel
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filters',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                // TODO: Navigate to profile/login screen
              },
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both sections in parallel
          await Future.wait([
            ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
            ref.read(messViewModelProvider.notifier).refreshMenu(),
          ]);
        },
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              GreetingSection(),

              // Shuttle Tracker
              ShuttleTrackerSection(),

              SizedBox(height: 20),

              // Today's Mess Menu preview
              TodaysMessPreviewSection(),

              SizedBox(height: 20),

              // Quick actions
              QuickActionsSection(),

              // Bottom padding for navigation bar clearance
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
