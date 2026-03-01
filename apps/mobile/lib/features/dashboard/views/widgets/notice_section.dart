import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/view_models/notice_view_model.dart';
import 'package:iitpkd_one/features/dashboard/views/widgets/notice_card.dart';
import 'package:iitpkd_one/shared/widgets/section_header.dart';

/// The Real-time Updates section of the dashboard.
///
/// Displays today's notices with a "History" link to view past notices.
class NoticeSection extends ConsumerWidget {
  const NoticeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeAsync = ref.watch(noticeViewModelProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Real-time Updates',
          trailing: TextButton(
            onPressed: () {
              // TODO: Navigate to notice history screen
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'History',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),

        // Content
        noticeAsync.when(
          data: (notices) {
            if (notices.isEmpty) {
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All caught up! No new updates.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (int i = 0; i < notices.length; i++)
                  NoticeCard(
                    notice: notices[i],
                    postedTimeAgo: _getMockTimeAgo(i),
                    onDismiss: () => ref
                        .read(noticeViewModelProvider.notifier)
                        .dismissNotice(notices[i].id),
                    onAddToCalendar: notices[i].isCritical
                        ? null
                        : () {
                            // TODO: Implement calendar integration
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "${notices[i].title}" to calendar',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
          error: (error, _) => Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load updates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => ref
                        .read(noticeViewModelProvider.notifier)
                        .refreshNotices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a mock "time ago" string for demo purposes.
  /// In production, this would be calculated from the notice's timestamp.
  String _getMockTimeAgo(int index) {
    const times = ['15m ago', '2h ago', '4h ago'];
    return times[index % times.length];
  }
}
