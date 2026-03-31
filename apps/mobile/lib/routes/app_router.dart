import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iitpkd_one/features/dashboard/views/dashboard_screen.dart';
import 'package:iitpkd_one/features/faculty/views/faculty_detail_screen.dart';
import 'package:iitpkd_one/features/faculty/views/faculty_screen.dart';
import 'package:iitpkd_one/features/mess_menu/views/mess_menu_screen.dart';
import 'package:iitpkd_one/features/search/views/search_screen.dart';
import 'package:iitpkd_one/features/shuttle_schedule/views/shuttle_schedule_screen.dart';
import 'package:iitpkd_one/routes/app_shell.dart';

/// Placeholder screen for tabs that are not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$title — Coming Soon',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
              builder: (context, state) => const _PlaceholderScreen(
                title: 'Competitions',
                icon: Icons.emoji_events_rounded,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
