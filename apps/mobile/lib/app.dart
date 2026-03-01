import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/core/theme/app_theme.dart';
import 'package:iitpkd_one/routes/app_router.dart';

/// Root application widget.
///
/// Uses [ConsumerWidget] to enable Riverpod access at the app level.
/// Configures Material 3 theming and GoRouter navigation.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'IIT-PKD ONE',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
    );
  }
}
