import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:csquare_connect/features/competitions/views/competitions_screen.dart';
import 'package:csquare_connect/features/dashboard/views/dashboard_screen.dart';
import 'package:csquare_connect/features/faculty/views/faculty_detail_screen.dart';
import 'package:csquare_connect/features/faculty/views/faculty_screen.dart';
import 'package:csquare_connect/features/colab/views/colab_screen.dart';
import 'package:csquare_connect/features/colab/views/colab_detail_screen.dart';
import 'package:csquare_connect/features/colab/views/colab_requests_screen.dart';
import 'package:csquare_connect/features/colab/views/create_colab_screen.dart';
import 'package:csquare_connect/features/mess_menu/views/mess_menu_screen.dart';
import 'package:csquare_connect/features/profile/views/profile_screen.dart';
import 'package:csquare_connect/features/search/views/search_screen.dart';
import 'package:csquare_connect/features/shuttle_schedule/views/shuttle_schedule_screen.dart';
import 'package:csquare_connect/routes/app_shell.dart';

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
    // Search screen — pushed full-screen over the nav shell
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),

    // Mess menu — pushed full-screen over the nav shell
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

    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Colab routes — pushed full-screen over the nav shell
    GoRoute(
      path: '/colab/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateColabScreen(),
    ),
    GoRoute(
      path: '/colab/requests',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ColabRequestsScreen(),
    ),
    GoRoute(
      path: '/colab/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ColabDetailScreen(id: id);
      },
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
              builder: (context, state) => const ColabScreen(),
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
