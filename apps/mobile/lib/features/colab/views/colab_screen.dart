import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';
import 'package:csquare_connect/features/colab/data/models/colab_type.dart';
import 'package:csquare_connect/features/colab/view_models/colab_view_model.dart';
import 'package:csquare_connect/features/colab/view_models/providers.dart';
import 'package:csquare_connect/routes/app_shell.dart';
import 'package:csquare_connect/shared/widgets/app_logo_title.dart';

class ColabScreen extends HookConsumerWidget {
  const ColabScreen({super.key});

  Future<void> _joinColab(BuildContext context, WidgetRef ref, ColabItem item) async {
    try {
      final repo = ref.read(colabRepositoryProvider);
      await repo.createJoinRequest(colabId: item.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join request sent!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(colabViewModelProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by type',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: viewModel.typeFilter == null,
                    onSelected: (_) {
                      viewModel.filterByType(null);
                      Navigator.of(ctx).pop();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Project'),
                    selected: viewModel.typeFilter == ColabType.project,
                    onSelected: (_) {
                      viewModel.filterByType(ColabType.project);
                      Navigator.of(ctx).pop();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Job'),
                    selected: viewModel.typeFilter == ColabType.job,
                    onSelected: (_) {
                      viewModel.filterByType(ColabType.job);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colabAsync = ref.watch(colabViewModelProvider);
    final viewModel = ref.read(colabViewModelProvider.notifier);
    final bottomPadding = mainTabBottomPadding(context, extra: 12);

    final searchController = useTextEditingController();
    final focusNode = useFocusNode();

    useEffect(() {
      if (searchController.text.isEmpty && viewModel.searchQuery.isNotEmpty) {
        searchController.text = viewModel.searchQuery;
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
      }

      void listener() {
        viewModel.updateSearchQuery(searchController.text);
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    ref.listen(colabViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load colabs')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle(title: 'Collab'),
        actions: [
          IconButton(
            onPressed: () => context.push('/colab/requests'),
            icon: const Icon(Icons.mail_outline_rounded),
            tooltip: 'Requests',
          ),
          IconButton(
            onPressed: () => _showFilterSheet(context, ref),
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filters',
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: _SearchBar(
                  controller: searchController,
                  focusNode: focusNode,
                  onClear: () {
                    searchController.clear();
                    viewModel.clearSearch();
                  },
                ),
              ),
              Expanded(
                child: colabAsync.when(
                  data: (colabs) {
                    if (colabs.isEmpty) {
                      return _EmptyState(
                        onRetry: viewModel.refreshColabs,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: viewModel.refreshColabs,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                        itemCount: colabs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _IntroBanner(
                              count: colabs.length,
                              query: viewModel.searchQuery,
                            );
                          }
                          final item = colabs[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ColabCard(
                              item: item,
                              onView: () => context.push('/colab/${item.id}'),
                              onJoin: () => _joinColab(context, ref, item),
                            ),
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
                  error: (_, _) => _EmptyState(
                    onRetry: viewModel.refreshColabs,
                    message: 'Unable to load colabs right now.',
                  ),
                ),
              ),
            ],
          ),
          _FloatingCreateBar(
            bottomPadding: MediaQuery.of(context).padding.bottom,
            onCreate: () => context.push('/colab/create'),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          elevation: 1,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search colabs...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: onClear,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Clear',
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.count, required this.query});

  final int count;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final label = query.isEmpty
        ? '$count active colabs'
        : '$count match${count == 1 ? '' : 'es'} for "$query"';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.85),
            cs.secondaryContainer.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.onPrimaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find your next team',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColabCard extends StatelessWidget {
  const ColabCard({
    super.key,
    required this.item,
    required this.onView,
    required this.onJoin,
  });

  final ColabItem item;
  final VoidCallback onView;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelColor = item.type == ColabType.project
        ? cs.tertiary
        : cs.primary;
    final maxMembersLabel = item.maxMembers != null
        ? '${item.joinedCount}/${item.maxMembers} members'
        : '${item.joinedCount} members';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
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
                  color: labelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.type == ColabType.project ? 'Project' : 'Job',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (item.requirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.requirements,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                maxMembersLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                item.isActive
                    ? Icons.circle_rounded
                    : Icons.pause_circle_filled_rounded,
                size: 12,
                color: item.isActive ? cs.primary : cs.outline,
              ),
              const SizedBox(width: 6),
              Text(
                item.isActive ? 'Active' : 'Paused',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onJoin,
                  icon: const Icon(Icons.handshake_outlined, size: 18),
                  label: const Text('Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'No colabs found. Try adjusting filters.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCreateBar extends StatelessWidget {
  const _FloatingCreateBar({
    required this.bottomPadding,
    required this.onCreate,
  });

  final double bottomPadding;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomOffset = bottomPadding + kMainBottomNavOverlayHeight - 12;

    return Positioned(
      left: 20,
      right: 20,
      bottom: math.max(18, bottomOffset),
      child: Material(
        elevation: 6,
        color: cs.surface,
        shadowColor: cs.shadow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Create a new colab',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
