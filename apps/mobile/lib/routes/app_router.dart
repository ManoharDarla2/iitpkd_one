import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iitpkd_one/features/competitions/views/competitions_screen.dart';
import 'package:iitpkd_one/features/dashboard/views/dashboard_screen.dart';
import 'package:iitpkd_one/features/faculty/views/faculty_detail_screen.dart';
import 'package:iitpkd_one/features/faculty/views/faculty_screen.dart';
import 'package:iitpkd_one/features/mess_menu/views/mess_menu_screen.dart';
import 'package:iitpkd_one/features/search/views/search_screen.dart';
import 'package:iitpkd_one/features/shuttle_schedule/views/shuttle_schedule_screen.dart';
import 'package:iitpkd_one/routes/app_shell.dart';
import 'package:iitpkd_one/shared/widgets/main_tab_app_bar.dart';

/// Placeholder screen for tabs that are not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainTabAppBar(
        title: title,
        subtitle: 'Fresh updates landing soon',
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          mainTabBottomPadding(context, extra: 18),
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.52),
                  theme.colorScheme.surfaceContainerLow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 54, color: theme.colorScheme.primary),
                const SizedBox(height: 14),
                Text(
                  '$title is getting a full redesign',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We are crafting better layouts, smarter data blocks, and smoother interactions for this tab.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation key for each shell branch.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// The app's router configuration.
///
/// Uses a [StatefulShellRoute] with [GoRouter] to provide
/// Material 3 [NavigationBar] with tab-based navigation.
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/schedules/mess',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MessMenuScreen(),
    ),
    // Faculty detail — pushed full-screen over the nav shell
    GoRoute(
      path: '/faculty/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return FacultyDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/faculty',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FacultyScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Home (Dashboard)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Shuttle Schedule (main bottom tab)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedules/shuttle',
              builder: (context, state) => const ShuttleScheduleScreen(),
            ),
          ],
        ),

        // Collab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/collab',
              builder: (context, state) => const _PlaceholderScreen(
                title: 'Collab',
                icon: Icons.groups_rounded,
              ),
            ),
          ],
        ),

        // Competitions
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/competitions',
              builder: (context, state) => const CompetitionsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
