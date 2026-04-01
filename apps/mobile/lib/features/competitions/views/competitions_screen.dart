import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/competitions/data/models/competition.dart';
import 'package:iitpkd_one/features/competitions/view_models/competition_view_model.dart';
import 'package:iitpkd_one/shared/widgets/main_tab_app_bar.dart';

class CompetitionsScreen extends ConsumerWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionsAsync = ref.watch(competitionViewModelProvider);
    final viewModel = ref.read(competitionViewModelProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    ref.listen(competitionViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load competitions')),
        );
      }
    });

    return Scaffold(
      appBar: const MainTabAppBar(
        title: 'Competitions',
        subtitle: 'External opportunities for teams',
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshCompetitions(),
        child: competitionsAsync.when(
          data: (competitions) {
            if (competitions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    child: Center(
                      child: Text(
                        'No competitions available right now.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: competitions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer.withValues(alpha: 0.78),
                          cs.secondaryContainer.withValues(alpha: 0.76),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      'Track upcoming robotics and aerospace competitions. Pull to refresh for latest updates.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        height: 1.35,
                      ),
                    ),
                  );
                }

                final item = competitions[index - 1];
                return _CompetitionCard(item: item);
              },
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
          error: (_, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: () => viewModel.refreshCompetitions(),
                    child: const Text('Retry loading competitions'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({required this.item});

  final Competition item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final daysLeft = item.daysLeft;
    final urgencyColor = daysLeft < 0
        ? cs.error
        : daysLeft <= 7
        ? cs.tertiary
        : cs.primary;
    final deadlineText = daysLeft < 0
        ? 'Closed'
        : daysLeft == 0
        ? 'Last day'
        : '$daysLeft days left';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  deadlineText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: urgencyColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Deadline: ${item.deadlineLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.websiteUrl,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _copyToClipboard(
                  context,
                  'Website link copied',
                  item.websiteUrl,
                ),
                icon: const Icon(Icons.public_rounded, size: 18),
                label: const Text('Copy Website'),
              ),
              FilledButton.icon(
                onPressed: () => _copyToClipboard(
                  context,
                  'Apply link copied',
                  item.applyLink,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Copy Apply Link'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String message,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
