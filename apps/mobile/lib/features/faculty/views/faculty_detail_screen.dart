import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/faculty/view_models/faculty_detail_view_model.dart';
import 'package:iitpkd_one/features/faculty/views/widgets/faculty_contact_row.dart';
import 'package:iitpkd_one/features/faculty/views/widgets/faculty_detail_header.dart';
import 'package:iitpkd_one/features/faculty/views/widgets/faculty_info_section.dart';

/// Faculty detail/profile screen.
///
/// Pushed as a full-screen route (over the navigation shell) so the
/// bottom bar is hidden. Shows all available information for a
/// specific faculty member.
class FacultyDetailScreen extends HookConsumerWidget {
  const FacultyDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(facultyDetailViewModelProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.when(
          data: (detail) => Text(
            detail.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Faculty'),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: detailAsync.when(
        data: (detail) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(facultyDetailViewModelProvider(slug));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header (avatar, name, designation, department)
                FacultyDetailHeader(detail: detail),

                // Divider
                Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 12),

                // Contact info
                if (detail.contact != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FacultyContactRow(contact: detail.contact!),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                ],

                // All info sections
                Align(
                  alignment: Alignment.centerLeft,
                  child: FacultyInfoSection(detail: detail),
                ),

                // Bottom padding
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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
                'Failed to load faculty profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(facultyDetailViewModelProvider(slug)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
