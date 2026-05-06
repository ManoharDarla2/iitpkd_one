import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/core/auth/auth_provider.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';
import 'package:csquare_connect/features/colab/data/models/colab_type.dart';
import 'package:csquare_connect/features/colab/view_models/colab_detail_providers.dart';
import 'package:csquare_connect/features/colab/view_models/colab_view_model.dart';
import 'package:csquare_connect/features/colab/view_models/providers.dart';

class ColabDetailScreen extends HookConsumerWidget {
  const ColabDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(colabDetailProvider(id));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authUser = ref.watch(authNotifierProvider).user;
    final repo = ref.read(colabRepositoryProvider);
    final isJoining = useState(false);

    ref.listen(colabDetailProvider(id), (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load colab detail')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detailAsync.asData?.value.title ?? 'Colab',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: detailAsync.whenOrNull(
          data: (colab) {
            if (colab.createdBy == authUser?.id) {
              return [
                IconButton(
                  onPressed: () => _showDeleteDialog(context, ref, colab),
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete',
                ),
              ];
            }
            return null;
          },
        ),
      ),
      body: detailAsync.when(
        data: (colab) => _DetailContent(
          colab: colab,
          authUserId: authUser?.id,
          isJoining: isJoining.value,
          onJoin: () async {
            if (isJoining.value) return;
            isJoining.value = true;
            try {
              await repo.createJoinRequest(colabId: colab.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join request sent!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              ref.invalidate(colabDetailProvider(id));
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } finally {
              isJoining.value = false;
            }
          },
        ),
        loading: () => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load colab',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(colabDetailProvider(id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ColabItem colab,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete colab'),
        content: Text('Are you sure you want to delete "${colab.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(colabRepositoryProvider).deleteColab(id: colab.id);
        if (!context.mounted) return;
        ref.invalidate(colabViewModelProvider);
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.colab,
    this.authUserId,
    required this.isJoining,
    required this.onJoin,
  });

  final ColabItem colab;
  final String? authUserId;
  final bool isJoining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isOwner = colab.createdBy == authUserId;
    final labelColor =
        colab.type == ColabType.project ? cs.tertiary : cs.primary;
    final maxMembersLabel = colab.maxMembers != null
        ? '${colab.joinedCount}/${colab.maxMembers} members'
        : '${colab.joinedCount} members';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (colab.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                colab.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.image_outlined,
                      size: 64, color: cs.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  colab.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: labelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  colab.type == ColabType.project ? 'Project' : 'Job',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.people_alt_rounded,
                  size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(maxMembersLabel,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: 16),
              Icon(
                colab.isActive
                    ? Icons.circle_rounded
                    : Icons.pause_circle_filled_rounded,
                size: 14,
                color: colab.isActive ? cs.primary : cs.outline,
              ),
              const SizedBox(width: 6),
              Text(
                colab.isActive ? 'Active' : 'Paused',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          if (colab.startDate != null || colab.endDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (colab.startDate != null) ...[
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(colab.startDate!),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                if (colab.startDate != null && colab.endDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('—',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                if (colab.endDate != null)
                  Text(
                    _formatDate(colab.endDate!),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text('Description',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(colab.description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.45)),
          if (colab.requirements.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Requirements',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(colab.requirements,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.45)),
          ],
          const SizedBox(height: 10),
          Text(
            'Created by $authUserId',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ),
          if (colab.isActive && !isOwner) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isJoining ? null : onJoin,
                icon: isJoining
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.handshake_outlined),
                label: Text(isJoining ? 'Sending...' : 'Send Join Request'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
