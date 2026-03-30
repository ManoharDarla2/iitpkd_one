import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/faculty/view_models/faculty_list_view_model.dart';
import 'package:iitpkd_one/features/faculty/views/widgets/department_filter_chips.dart';
import 'package:iitpkd_one/features/faculty/views/widgets/faculty_card.dart';

/// The main Faculty list screen — a bottom tab of the app.
///
/// Uses [HookConsumerWidget] to match the pattern from dashboard/schedule.
/// Displays a searchable, filterable list of all faculty members.
class FacultyScreen extends HookConsumerWidget {
  const FacultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final facultyAsync = ref.watch(facultyListViewModelProvider);
    final viewModel = ref.read(facultyListViewModelProvider.notifier);

    // Listen for errors
    ref.listen(facultyListViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Failed to load faculty');
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Faculty Directory',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Department filter chips
          facultyAsync.when(
            data: (_) => DepartmentFilterChips(
              departments: viewModel.departments,
              selected: viewModel.selectedDepartment,
              onSelected: (dept) => viewModel.filterByDepartment(dept),
            ),
            loading: () => const SizedBox(height: 42),
            error: (_, _) => const SizedBox(height: 42),
          ),

          const SizedBox(height: 8),

          // Faculty list
          Expanded(
            child: facultyAsync.when(
              data: (faculty) {
                if (faculty.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No faculty found for this department.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshFacultyList(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: faculty.length,
                    itemBuilder: (context, index) {
                      final member = faculty[index];
                      return FacultyCard(
                        faculty: member,
                        onTap: () {
                          context.push('/faculty/${member.slug}');
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load faculty',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => viewModel.refreshFacultyList(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
