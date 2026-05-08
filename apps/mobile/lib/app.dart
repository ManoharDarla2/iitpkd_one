import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/core/theme/app_theme.dart';
import 'package:csquare_connect/routes/app_router.dart';

/// Root application widget.
///
/// Uses [ConsumerWidget] to enable Riverpod access at the app level.
/// Configures Material 3 theming and GoRouter navigation.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CSquare Connect',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
    );
  }
}
