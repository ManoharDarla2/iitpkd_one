
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/core/theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: App()));

class App extends StatelessWidget {
  const App({super.key});

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IIT-PKD ONE',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
    );
  }
}

// A demo screen to test the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IIT PKD ONE'),
      ),
      body: const Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}