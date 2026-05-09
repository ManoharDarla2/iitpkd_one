import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:csquare_connect/features/dashboard/view_models/shuttle_view_model.dart';
import 'package:csquare_connect/features/dashboard/views/widgets/quick_actions_section.dart';
import 'package:csquare_connect/features/dashboard/views/widgets/live_updates_section.dart';
import 'package:csquare_connect/features/schedule/view_models/mess_view_model.dart';
import 'package:csquare_connect/routes/app_shell.dart';
import 'package:csquare_connect/shared/widgets/app_logo_title.dart';
import 'package:csquare_connect/shared/widgets/profile_avatar_action.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
        title: const AppLogoTitle(title: 'CSquare Connect'),
        actions: const [ProfileAvatarAction()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surface, cs.surfaceContainerLowest, cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(shuttleViewModelProvider.notifier).refreshSchedules(),
              ref.read(messViewModelProvider.notifier).refreshMenu(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  mainTabBottomPadding(context, extra: 6),
                ),
                sliver: SliverList.list(
                  children: [
                    _GreetingHeader(),
                    const SizedBox(height: 16),
                    const LiveUpdatesSection(),
                    const SizedBox(height: 24),
                    const QuickActionsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting.',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
